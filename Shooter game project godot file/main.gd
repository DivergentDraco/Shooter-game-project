
#This is the main code, it has important nodes and the majority of game functions operates in here.
#
#Here's how it works:
	#1. Add instances and variables, enemy scenes must be pre-made and preload them
	#2. With the player in the scene, ready the scene with start button and hide game over button
	#3. Spawn enemies in waves, each waves got calibrated inside its scene. It will continue to the next wave after every enemies got defeated (This operates inside func _process())
#
#If the player crashed into a bullet or enemy, the player dies.

extends Node2D

#Preloads enemy scenes
@onready var resource_preloader = $ResourcePreloader

#Sets initial score
var score = 0
#Sets initial playing state
var playing = false
#Sets initial amount of enemy
var enemy_number = 0
# Counts the total number of enemies instantiated
var total_enemies_instantiated: int = 0
@onready var start_button = $CanvasLayer/CenterContainer/Start
@onready var game_over = $CanvasLayer/CenterContainer/GameOver

#Declare variable current wave as integer
var current_wave: int
@export var enemy_scene: PackedScene
var wave: int = 0
var allow_next_wave: bool = true

func _ready():
	game_over.hide()
	start_button.show()
	
func _on_enemy_died(value):
	score += value
	$CanvasLayer/UI.update_score(score)
	$Camera2D.add_trauma(0.5)

func _process(_delta):
	if Input.is_action_pressed("shoot") and playing == false:
		Spawning.clear_all_bullets()
		start_button.hide()
		new_game()	

	# print(total_enemies_instantiated)
	if playing == true and total_enemies_instantiated == 0 and allow_next_wave == true:
		wave += 1; 
		# print("Wave changed! Now at wave:", wave)
		match wave:
			1: spawn_enemies("EnemyScene6", 1, 1, 0.0)
			2: 
				spawn_enemies("EnemyScene1", 20, 2, 0.2)
				spawn_enemies("EnemyScene3", 4, 1, 1.0)
			3: spawn_enemies("EnemyScene2", 4, 2, 1.0)
			4: spawn_enemies("EnemyScene3", 4, 1, 1.0)
			5: spawn_enemies("EnemyScene4", 10, 2, 0.5)
			

func _on_player_died():
	playing = false
	get_tree().call_group("enemies", "queue_free")
	game_over.show()
	await get_tree().create_timer(2).timeout
	game_over.hide()
	start_button.show()
	
func _on_start_pressed():
	if Input.is_action_pressed("shoot"):
		Spawning.clear_all_bullets()
		start_button.hide()
		new_game()	
	
func new_game():
	$StageMusic.play()
	score = 0
	$CanvasLayer/UI.update_score(score)
	$CanvasLayer/CenterContainer/Player.start()
	playing = true

#Enemy exits the area and despawns
func _on_area_2d_area_exited(area):
	if area.is_in_group("enemies"):
		total_enemies_instantiated -= 1

# Generalized enemy spawning function
func spawn_enemies(scene_name: String, count: int, enemy_amount: int, delay: float):
	for i in count:
		allow_next_wave = false
		var e = resource_preloader.get_resource(scene_name).instantiate()
		add_child(e)
		total_enemies_instantiated += (enemy_amount * 1)
		await get_tree().create_timer(delay).timeout
	allow_next_wave = true
