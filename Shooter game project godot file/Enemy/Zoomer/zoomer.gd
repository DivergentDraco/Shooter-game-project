class_name Zoomer
extends CharacterBody2D

enum BossState {
	ATTACK_1,
}

var player: Area2D

var attack_direction := Vector2.ZERO

var original_position: Vector2
var next_state: BossState

@export var state: BossState = BossState.ATTACK_1
@export var move_speed = 50
@export var acceleration = 200
@export var min_speed = 0
var attack_center: Vector2
var state_time := 0.0

@export var speed: float = 2.0       
@export var radius: float = 100     
@export var center_point: Vector2 = original_position 

var angle: float = 0.0

signal died 
@onready var movement_pattern = $MovementPattern
@onready var screensize  = get_viewport_rect().size
@onready var hit_flash_anim_player = $HitFlashAnimationPlayer
@onready var spawn_points = {
	"spawnpoint_1" : $SpawnPoint,
}

var bullet_scene = preload("res://enemy_bullet.tscn")
var hp = 1

func _ready() -> void:
	player = get_tree().get_first_node_in_group("players")

	if player:
		attack_direction = global_position.direction_to(player.global_position)
		print("Locked direction: ", attack_direction)

func _physics_process(delta: float) -> void:
	move_speed = clamp(move_speed, min_speed, 1000)
	state_time += delta

	match state:
		BossState.ATTACK_1:
			attack_1(delta)
	move_and_slide()

func change_state(new_state: BossState) -> void:
	print("Changing state: ", state, " -> ", new_state)
	
	state = new_state
	state_time = 0.0
	
	for point in spawn_points.values():
		point.active = false
		
	match state:
		BossState.ATTACK_1:
			var point = spawn_points["spawnpoint_1"]
			point.active = true
			point.spawn()
			

func attack_1(delta: float) -> void:
	set_collision_layer_value(2, true)
	
	move_speed += acceleration * delta
	
	velocity = attack_direction * move_speed
	
func set_movement_pattern(new_pattern):
	movement_pattern.pattern = new_pattern

func set_movement_speed(new_speed: float) -> void:
	movement_pattern.speed = new_speed
	
func set_acceleration(new_acceleration: float) -> void:
	movement_pattern.acceleration = new_acceleration

func set_max_speed(new_max_speed: float) -> void:
	movement_pattern.max_speed = new_max_speed
	
func set_min_speed(new_min_speed: float) -> void:
	movement_pattern.min_speed = new_min_speed

func set_straight_direction(x: float, y: float) -> void:
	movement_pattern.straight_x = x
	movement_pattern.straight_y = y

func set_movement_direction(new_direction: Vector2) -> void:
	print("Setting direction to: ", new_direction)
	movement_pattern.direction = new_direction
	
func set_spawnpoint(index: int) -> void:
	var spawnpoint_1 = get_node("SpawnPoint")

	match index:
		1:
			spawnpoint_1.active = true

func explode():
	if hp > 0:
		hp -= 1
		hit_flash_anim_player.play("hit_flash")
	else: 
		set_collision_layer_value(2, false)
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("explode")
		set_deferred("monitorable", false)
		died.emit(5)
		$ExplodeSFX.play()
		await $AnimatedSprite2D.animation_finished
		#Spawning.clear_all_bullets()
		queue_free()

var has_entered_screen := false


func _on_visible_on_screen_notifier_2d_screen_entered():
	has_entered_screen = true


func _on_visible_on_screen_notifier_2d_screen_exited():
	if has_entered_screen:
		queue_free()
