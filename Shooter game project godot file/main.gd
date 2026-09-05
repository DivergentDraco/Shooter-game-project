extends Node2D

#Preloads enemy scenes
@onready var resource_preloader = $ResourcePreloader

var score = 0
#Sets initial playing state
var playing = false
#Sets initial amount of enemy
@onready var stage_manager = $StageManager
@onready var start_button = $CanvasLayer/CenterContainer/VBoxContainer
@onready var game_over = $CanvasLayer/CenterContainer/GameOver

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
	stage_manager.start_stage()
	$StageMusic.play()
	score = 0
	$CanvasLayer/UI.update_score(score)
	$CanvasLayer/CenterContainer/Player.start()
	playing = true
