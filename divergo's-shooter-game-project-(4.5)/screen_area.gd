extends Area2D
var inside

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_area_exited(area): # Area Exited Function
	if(area.is_in_group("enemies")):
		area.set_visible(false)
	
