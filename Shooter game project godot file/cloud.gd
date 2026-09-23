extends Sprite2D
@export var start_position := Vector2(123.0, -200.0)

func _ready() -> void:
	hide()

func start() -> void:
	global_position = start_position

	show()
	var tween = create_tween()
	# Move 300 pixels to the right over 2.0 seconds
	tween.tween_property(self, "position:y", position.y + 1000, 2.0) \
		.set_trans(Tween.TRANS_LINEAR)
