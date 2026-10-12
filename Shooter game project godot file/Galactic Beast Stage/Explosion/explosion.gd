extends AnimatedSprite2D

func _ready() -> void:
	play("explosion1")
	animation_finished.connect(queue_free)
