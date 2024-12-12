extends Node2D

signal died 

var start_pos = Vector2.ZERO
var speed = 100
var bullet_scene = preload("res://enemy_bullet.tscn")
var anchor
var follow_anchor = false
var hp = 3

@onready var screensize  = get_viewport_rect().size

func start(pos):
	follow_anchor = false
	speed = 50
	start_pos = pos
	await get_tree().create_timer(randf_range(0.25, 0.55)).timeout
	var tw = create_tween().set_trans(Tween.TRANS_BACK)
	await tw.finished
	follow_anchor = true
	$ShootTimer.wait_time = randf_range(4, 20)
	$ShootTimer.start()

func _on_shoot_timer_timeout():
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(position)
	$ShootTimer.wait_time = randf_range(4, 20)
	$ShootTimer.start()
