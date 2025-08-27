extends Area2D

#set signal
signal shield_changed()
signal died()
#set variables
@export var speed = 150
@export var cooldown = 0.06
@export var max_shield = 1
@export var bullet_scene : PackedScene

#onready variables and nodes
@onready var ship = $Node2D1/Ship
@onready var boosters = $Node2D1/Ship/Boosters
@onready var shiftind = $Node2D1/ShiftInd

@onready var screensize = get_viewport_rect().size
#adding array variable for storing player positions
var array = PackedVector2Array()

#declare variable shield
var shield = max_shield

#declare variable can_shoot
var can_shoot = true
# bullet mode: 0 = straight, 1 = spiral
var bullet_mode = 0

#
func _ready():
	array.resize(10)
	start()

func start():
	show()
	set_process(true)
	position = Vector2(screensize.x/2, screensize.y - 50)
	$Node2D1/GunCooldown.wait_time = cooldown
	
func _process(delta):
#Move key
	var input = Input.get_vector("left", "right", "up", "down")
	if input.x > 0:
		ship.frame = 2
		boosters.animation = "right"
	elif input.x < 0:
		ship.frame = 0
		boosters.animation = "left"
	else:
		ship.frame = 1
		boosters.animation = "forward"
#Shift key
	if Input.is_action_pressed("focus"):
		speed = 75
		shiftind.visible = true
	else:
		speed = 150
		shiftind.visible = false
#calculate speed and position
	position += input * speed * delta

#Store positions into arrays
	# print(array)
	if $Node2D1.position != array[0]:
		array.insert(0, $Node2D1.position)
	array.resize(20)
#Select the 10th position stored in the array
	$Node2D2.position = array[10]

#Limit the player only inside the box	
	# position = position.clamp(Vector2(8+165, 8), screensize - Vector2(173, 8))
	position = position.clamp(Vector2(8, 8), screensize - Vector2(8, 8))

	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

	if Input.is_action_just_pressed("switch"):
		bullet_mode = 1 - bullet_mode # toggle between 0 and 1

func shoot():
	can_shoot = false
	$Node2D1/GunCooldown.start()
	$Node2D1/AudioStreamPlayer.play()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	var bullet_offset = Vector2(159, 0) # half bullet size
	b.start(position + bullet_offset, bullet_mode)
	await get_tree().create_timer(0.045).timeout
	can_shoot = true

func set_shield(value):
	shield = min(max_shield, value)
	shield_changed.emit(max_shield, shield)
	if shield == 0:
		set_process(false)
		hide()
		#emits died() signal for main.gd to detect
		died.emit()

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.explode()
		shield -= max_shield / 2.0
