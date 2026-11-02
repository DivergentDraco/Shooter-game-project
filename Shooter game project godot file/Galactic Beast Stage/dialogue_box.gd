extends Control


const SLOT_LEFT = 0
const SLOT_RIGHT = 1

const STEP_START = "start"

@export var dialogue_resource: DialogueResource

## The action to use for advancing the dialogue
@export var next_action: StringName = "Z"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = "Z"

var _is_waiting_for_input: bool = false

var _dialogue_line: DialogueLine:
	set(value):
		_dialogue_line = value
		_apply_dialogue_line()
	get:
		return _dialogue_line
		
var story_step: String = STEP_START

var slots: Array[Marker2D] = []
var characters: Dictionary = {}

@onready var character_label: RichTextLabel = %CharacterLabel
@onready var dialogue_label: DialogueLabel = %DialogueLabel
@onready var slot_0: Marker2D = %Slot0
@onready var slot_1: Marker2D = %Slot1

@export var inactive_brightness: float = 0.5
@export var active_brightness: float = 1.0
@export var brightness_transition: float = 0.2

var portrait_tweens: Dictionary = {}

@onready var typing_sound: AudioStreamPlayer2D = %TypingSound


func _ready() -> void:
	slots = [slot_0, slot_1]

	character_label.text = ""
	dialogue_label.text = ""
	
	dialogue_label.spoke.connect(_on_dialogue_label_spoke)

	# Dim any already-registered portraits.
	update_portrait_brightness("")

	if dialogue_resource == null:
		push_error("Dialogue resource not assigned!")
		return

	_dialogue_line = await dialogue_resource.get_next_dialogue_line(
	"start",
	[self]
	)

func _on_dialogue_label_spoke(_letter: String, _letter_index: int, _speed: float) -> void:
	typing_sound.play()

#region Dialogue


func _apply_dialogue_line() -> void:
	_is_waiting_for_input = false
	focus_mode = Control.FOCUS_ALL
	grab_focus()

	if not is_instance_valid(_dialogue_line):
		character_label.text = ""
		dialogue_label.text = ""
		return
		
	update_portrait_brightness(_dialogue_line.character)

	if _dialogue_line.character.is_empty():
		character_label.text = ""
		dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_dialogue_line.text = "[color=#4cc69c]%s[/color]" % [_dialogue_line.text]
	else:
		character_label.text = tr(_dialogue_line.character, "dialogue")
		dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

		if characters.has(_dialogue_line.character.to_lower()):
			characters[_dialogue_line.character.to_lower()].emote(_dialogue_line.tags)

	dialogue_label.dialogue_line = _dialogue_line

	character_label.show()
	dialogue_label.show()
	if not _dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	# Wait for input
	if _dialogue_line.responses.size() > 0:
		focus_mode = Control.FOCUS_NONE
	elif _dialogue_line.time != "":
		var time = _dialogue_line.text.length() * 0.02 if _dialogue_line.time == "auto" else _dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		_next(_dialogue_line.next_id)
	else:
		_is_waiting_for_input = true
		focus_mode = Control.FOCUS_ALL
		grab_focus()


func _next(next_id: String) -> void:
	_is_waiting_for_input = false
	_dialogue_line = await dialogue_resource.get_next_dialogue_line(
		next_id,
		[self]
	)


#endregion

#region Mutations

# Add a character to the current location.
func add_character(character_name: String, slot_index: int) -> void:
	var slot: Marker2D = slots[slot_index]

	if slot.get_child_count() > 0:
		await remove_character(slot.get_child(0).character_name)

	var character: BasePortrait = load(
		"res://Galactic Beast Stage/Characters/%s/portrait.tscn" % character_name
	).instantiate()

	slot.add_child(character)

	var target_position: Vector2 = slot.global_position
	var slide_distance: float = 100.0

	# Start completely transparent.
	# Start dimmed and transparent.
	character.modulate = Color(
		inactive_brightness,
		inactive_brightness,
		inactive_brightness,
		0.0
	)

	if slot_index == SLOT_LEFT:
		character.global_position = target_position + Vector2(slide_distance, 0)
	else:
		character.global_position = target_position + Vector2(-slide_distance, 0)
		character.scale = Vector2(-1, 1)

	# Animate movement and transparency simultaneously.
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)

	# Slide into position.
	tween.tween_property(
		character,
		"global_position",
		target_position,
		0.4
	)

	# Fade from transparent to fully visible.
	tween.tween_property(
		character,
		"modulate:a",
		1.0,
		0.4
	)

	# Register the character before the animation finishes.
	characters[character_name.to_lower()] = character

	await tween.finished

	# Update brightness based on whoever is currently speaking.
	if is_instance_valid(_dialogue_line):
		update_portrait_brightness(_dialogue_line.character)


# Remove a character from the current location
func remove_character(character_name: String) -> void:
	if not characters.has(character_name):
		return

	var character: BasePortrait = characters[character_name]

	var slide_distance: float = 500.0
	var target_position: Vector2 = character.global_position

	# Determine which slot contains the character.
	if character.get_parent() == slot_0:
		target_position.x -= slide_distance
	else:
		target_position.x += slide_distance

	# Slide out.
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)

	tween.tween_property(
		character,
		"global_position",
		target_position,
		0.3
	)

	await tween.finished

	characters.erase(character_name)
	character.queue_free()


#endregion

@export var speaking_offset: float = 10.0

func update_portrait_brightness(speaker_name: String) -> void:
	for character_name in characters:
		var character: BasePortrait = characters[character_name]

		if not is_instance_valid(character):
			continue

		var is_speaking: bool = character_name.to_lower() == speaker_name.to_lower()

		var target_brightness: float = active_brightness if is_speaking else inactive_brightness

		# Default position is the character's slot.
		var slot: Marker2D = character.get_parent() as Marker2D
		var target_position: Vector2 = slot.global_position
		
		character.z_index = 10 if is_speaking else 0
		
		# Move speaking characters toward the center.
		if is_speaking:
			if slot == slot_0:
				target_position.x += speaking_offset
			elif slot == slot_1:
				target_position.x -= speaking_offset

		# Stop previous animation.
		if portrait_tweens.has(character_name):
			var old_tween: Tween = portrait_tweens[character_name]
			if old_tween.is_running():
				old_tween.kill()

		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)

		# Animate brightness.
		tween.tween_property(
			character,
			"modulate:r",
			target_brightness,
			brightness_transition
		)
		tween.tween_property(character, "modulate:g", target_brightness, brightness_transition)
		tween.tween_property(character, "modulate:b", target_brightness, brightness_transition)

		# Animate horizontal movement.
		tween.tween_property(
			character,
			"global_position",
			target_position,
			brightness_transition
		)

		portrait_tweens[character_name] = tween

#region Signals


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(next_action) or event.is_echo():
		return

	# If text is still typing, reveal it immediately.
	if dialogue_label.is_typing:
		dialogue_label.skip_typing()
		get_viewport().set_input_as_handled()
		return

	# Only advance when waiting for input.
	if not _is_waiting_for_input:
		return

	if _dialogue_line.responses.size() > 0:
		return

	# Advance to the next dialogue line.
	get_viewport().set_input_as_handled()
	_next(_dialogue_line.next_id)


func _on_responses_menu_response_selected(response: Variant) -> void:
	_next(response.next_id)


#endregion
