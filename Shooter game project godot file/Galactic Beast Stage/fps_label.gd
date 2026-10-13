extends Label

func _process(_delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	text = "FPS: %d" % fps

	if fps < 30:
		modulate = Color.ORANGE_RED
	elif fps < 60:
		modulate = Color.YELLOW
	else:
		modulate = Color.WHITE
