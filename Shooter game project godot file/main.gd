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
@onready var resource_preloader = $ResourcePreloader

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
	
func _on_enemy_died(value):
	score += value
	$CanvasLayer/UI.update_score(score)
	$Camera2D.add_trauma(0.5)

func _process(_delta):
	print(global.enemy_value)
	if playing == true:
		if global.enemy_value == 0:
			if wave == 1:
				spawn_enemies1()
			if wave == 2:
				spawn_enemies2()
			if wave == 3:
				spawn_enemies3()
			if wave == 4:
				spawn_enemies4()

func _on_player_died():
	playing = false
	get_tree().call_group("enemies", "queue_free")
	global.enemy_value = 0
	game_over.show()
	await get_tree().create_timer(2).timeout
	game_over.hide()
	start_button.show()
	
func _on_start_pressed():
	Spawning.clear_all_bullets()
	start_button.hide()
	new_game()	
	
func new_game():
	$StageMusic.play()
	score = 0
	$CanvasLayer/UI.update_score(score)
	$CanvasLayer/CenterContainer/Player.start()
	playing = true
	spawn_enemies1()

#Enemy exits the area and despawns
func _on_area_2d_area_exited(area):
	if area.is_in_group("enemies"):
		global.enemy_value -= 1

"""
The following section sets the enemy's waves
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
"""

func spawn_enemies1():
	#IMPORTANT: set global.enemy_value equals to the amount of enemies its going to spawn (refer to how much n(rounds) you add and the enemies in the scene)
	global.enemy_value = 6
	for n in 3:
		var e = resource_preloader.get_resource("EnemyScene1").instantiate()
		add_child(e)
		await get_tree().create_timer(1).timeout
	#sets wave number to 2, sending back to func _process(_delta) to select the 2nd wave and so on
	wave = 2
	
func spawn_enemies2():
	global.enemy_value = 4
	for n in 2:
		var e = resource_preloader.get_resource("EnemyScene2").instantiate()
		add_child(e)
		await get_tree().create_timer(1).timeout
	wave = 3
		
func spawn_enemies3():
	global.enemy_value += 4
	for n in 4:
		var e = resource_preloader.get_resource("EnemyScene3").instantiate()
		add_child(e)
		await get_tree().create_timer(1).timeout
	wave = 4
		
func spawn_enemies4():
	while n < 1:
		var e = resource_preloader.get_resource("EnemyScene4").instantiate()
		add_child(e)
		await get_tree().create_timer(1).timeout
		n += 1
