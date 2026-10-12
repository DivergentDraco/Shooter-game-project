extends Node2D

#Preloads enemy scenes
@onready var resource_preloader = $ResourcePreloader

var score = 0
#Sets initial playing state
var playing = false
#Sets initial amount of enemy
@onready var stage_manager = $StageManager
@onready var start_button = $CanvasLayer/Control/CenterContainer/VBoxContainer
@onready var game_over = $CanvasLayer/Control/CenterContainer/GameOver

func _ready():
	get_window().content_scale_size = Vector2i(250, 320)
	game_over.hide()
	start_button.show()
	

func _process(_delta):
	if Input.is_action_pressed("Z") and playing == false:
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
	if Input.is_action_pressed("Z"):
		Spawning.clear_all_bullets()
		start_button.hide()
		new_game()
	
func new_game():
	stage_manager.start_stage()
	$StageMusic.play()
	score = 0
	$Player.start()
	playing = true
