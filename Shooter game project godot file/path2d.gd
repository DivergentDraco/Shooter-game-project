extends Path2D

var speed = 100

@onready var screensize  = get_viewport_rect().size
@onready var pathfollow:PathFollow2D = $PathFollow2D
	
func _process(delta: float) -> void:
	pathfollow.progress += speed * delta
	
	
