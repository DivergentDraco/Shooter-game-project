"""
This is the main code, it has important nodes and the majority of game functions operates in here.

Here's how it works:
	1. Add instances and variables, enemy scenes must be pre-made and preload them
	2. With the player in the scene, ready the scene with start button and hide game over button
	3. Spawn enemies in waves, each waves got calibrated inside its scene. It will continue to the next wave after every enemies got defeated (This operates inside func _process())

If the player crashed into a bullet or enemy, it dies.
	
"""

extends Node2D

#Preloads enemy scenes
var fairy_enemy = preload("res://fairy_enemy.tscn")
var fairy_enemy_right = preload("res://fairy_enemy_right.tscn")
var enemyscene1 = preload("res://EnemyScene1.tscn")
var enemyscene2 = preload("res://EnemyScene2.tscn")
var enemyscene3 = preload("res://EnemyScene3.tscn")
var enemyscene4 = preload("res://EnemyScene4.tscn")

#Sets score, n as enemies' number
var score = 0
var playing = false
var n = 0
@onready var start_button = $CanvasLayer/CenterContainer/Start
@onready var game_over = $CanvasLayer/CenterContainer/GameOver

var current_wave: int
@export var enemy_scene: PackedScene

var wave: int

func _ready():
	game_over.hide()
	start_button.show()
	var tween = create_tween().set_loops().set_parallel(false).set_trans(Tween.TRANS_SINE)
	tween.tween_property($EnemyAnchor, "position:x", $EnemyAnchor.position.x + 3, 1.0)
	tween.tween_property($EnemyAnchor, "position:x", $EnemyAnchor.position.x - 3, 1.0)
	var tween2 = create_tween().set_loops().set_parallel(false).set_trans(Tween.TRANS_BACK)
	tween2.tween_property($EnemyAnchor, "position:y", $EnemyAnchor.position.y + 3, 1.5).set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property($EnemyAnchor, "position:y", $EnemyAnchor.position.y - 3, 1.5).set_ease(Tween.EASE_IN_OUT)
		
func spawn_enemies1():
	global.enemy_value = 6
	for n in 3:
		var e = enemyscene1.instantiate()
		add_child(e)
		await get_tree().create_timer(1).timeout
	wave = 2
	
func spawn_enemies2():
	global.enemy_value = 4
	for n in 2:
		var e = enemyscene2.instantiate()
		add_child(e)
		await get_tree().create_timer(1).timeout
	wave = 1
		
func spawn_enemies3():
	global.enemy_value += 5
	for n in 4:
		var e = enemyscene3.instantiate()
		add_child(e)
		await get_tree().create_timer(1).timeout
	wave = 4
		
func spawn_enemies4():
	while n < 1:
		var e = enemyscene4.instantiate()
		add_child(e)
		await get_tree().create_timer(1).timeout
		n += 1

func _on_enemy_died(value):
	score += value
	$CanvasLayer/UI.update_score(score)
	$Camera2D.add_trauma(0.5)

func _process(_delta):
	if playing == true:
		
		#print(wave)
		if global.enemy_value == 0:
			if wave == 1:
				spawn_enemies1()
			if wave == 2:
				spawn_enemies2()
			if wave == 3:
				spawn_enemies3()
				
func _on_player_died():
#	print("game over")
	playing = false
	get_tree().call_group("enemies", "queue_free")
	game_over.show()
	await get_tree().create_timer(2).timeout
	game_over.hide()
	start_button.show()
	
func _on_start_pressed():
	start_button.hide()
	new_game()	
	
func new_game():
	$StageMusic.play()
	score = 0
	$CanvasLayer/UI.update_score(score)
	$Player.start()
	playing == true
	spawn_enemies1()

func _on_area_2d_area_exited(area):
	if area.is_in_group("enemies"):
		global.enemy_value -= 1
