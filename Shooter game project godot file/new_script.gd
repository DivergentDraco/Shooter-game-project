extends Node
var array = []
var n = 0

func _ready() -> void:
	for i in range(4):
		array += [0]
	print(array)
	array = [n, 2, 3, 3]
	$Timer.start()

func _on_timer_timeout() -> void:
	print(array)
	n = n+1
	if n != array[0]:
		array.push_front(n)
	array.resize(4)
