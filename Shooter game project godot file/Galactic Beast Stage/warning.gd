extends Sprite2D
@export var start_position := Vector2(-120.0, 150.0)

func _ready() -> void:
	hide()

func start() -> void:
	global_position = start_position

	show()
	var tween = create_tween()
	# Move 300 pixels to the right over 2.0 seconds
	tween.tween_property(self, "position:x", position.x + 580, 2.0) \
		.set_trans(Tween.TRANS_QUINT) \
		.set_ease(Tween.EASE_OUT_IN)
