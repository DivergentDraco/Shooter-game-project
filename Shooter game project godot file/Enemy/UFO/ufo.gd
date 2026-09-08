class_name Ufo
extends CharacterBody2D

enum BossState {
	ENTER,
	ATTACK_1,
	DEAD,
	RETURN,
	FLEE,
}

var original_position: Vector2
var next_state: BossState

@export var state: BossState = BossState.ENTER
@export var move_speed = 1000
@export var min_speed = 0
var attack_center: Vector2
var state_time := 0.0

@export var speed: float = 2.0        # How fast the enemy rotates
@export var radius: float = 100     # How big the circle is
@export var center_point: Vector2 = original_position # The middle of the circle

var angle: float = 0.0

signal died 
@onready var movement_pattern = $MovementPattern
@onready var screensize  = get_viewport_rect().size
@onready var hit_flash_anim_player = $HitFlashAnimationPlayer
@onready var spawn_points = {
	"spawnpoint_1" : $SpawnPoint,
	"spawnpoint_2" : $SpawnPoint2,
	"spawnpoint_3" : $SpawnPoint3,
}

var bullet_scene = preload("res://enemy_bullet.tscn")
var hp = 100

func _ready() -> void:
	change_state(BossState.ENTER)

func _physics_process(delta: float) -> void:
	move_speed = clamp(move_speed, min_speed, 1000)
	state_time += delta

	match state:
		BossState.ENTER:
			enter_state(delta)

		BossState.ATTACK_1:
			attack_1(delta)

		BossState.DEAD:
			velocity = Vector2.ZERO
			
		BossState.FLEE:
			flee(delta)
			
		BossState.RETURN:
			return_state(delta)

	move_and_slide()

func change_state(new_state: BossState) -> void:
	print("Changing state: ", state, " -> ", new_state)
	
	state = new_state
	state_time = 0.0
	
	for point in spawn_points.values():
		point.active = false
		
	match state:
		BossState.ATTACK_1:
			destination_origin = global_position
			destination_step = 0
			holding = false
			hold_time = 0.0
			set_next_destination()

			var point = spawn_points["spawnpoint_1"]
			point.active = true
			point.spawn()
			
func enter_state(_delta: float) -> void:
	var target_y: float = 30.0
	var distance: float = target_y - global_position.y

	var eased_speed: float = clampf(absf(distance) * 3.0, 20.0, move_speed)

	velocity.y = signf(distance) * eased_speed
	velocity.x = 0.0

	if absf(distance) < 1.0:
		global_position.y = target_y
		velocity = Vector2.ZERO

		original_position = global_position
		change_state(BossState.ATTACK_1)

func return_state(_delta: float) -> void:
	var distance: float = global_position.distance_to(original_position)

	if distance < 2.0:
		global_position = original_position
		velocity = Vector2.ZERO
		change_state(next_state)
		return

	var return_speed: float = clampf(distance * 3.0, 30.0, move_speed)

	velocity = global_position.direction_to(original_position) * return_speed

var destination : Vector2
var destination_origin: Vector2
var destination_step : int = 0
var holding := false
var hold_time : float = 0

@export var min_bounds := Vector2(30.0, 40.0)
@export var max_bounds := Vector2(220.0, 100.0)

func set_next_destination() -> void:
	destination_step += 1

	var t: float = destination_step * 0.8

	var center := Vector2(
		(min_bounds.x + max_bounds.x) / 2.0,
		(min_bounds.y + max_bounds.y) / 2.0
	)

	destination = center + Vector2(
		cos(t * 2.0) * 100.0,
		cos(t * 3.0) * 100.0
	)

	destination.x = clampf(
		destination.x,
		min_bounds.x,
		max_bounds.x
	)

	destination.y = clampf(
		destination.y,
		min_bounds.y,
		max_bounds.y
	)

func attack_1(delta: float) -> void:
	velocity = Vector2.ZERO

	if holding:
		hold_time += delta

		if hold_time >= 1.0:
			hold_time = 0.0
			holding = false
			set_next_destination()

		return

	global_position = global_position.move_toward(
		destination,
		move_speed * delta
	)

	if global_position.distance_to(destination) < 1.0:
		global_position = destination
		holding = true
		hold_time = 0.0

	if state_time >= 6.0:
		next_state = BossState.FLEE
		change_state(BossState.RETURN)

func flee(_delta: float) -> void:
	velocity.y = -100
		
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
	var spawnpoint_2 = get_node("SpawnPoint2")
	var spawnpoint_3 = get_node("SpawnPoint3")

	match index:
		1:
			spawnpoint_1.active = true
		2:
			spawnpoint_2.active = true
		3:
			spawnpoint_3.active = true

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
		Spawning.clear_all_bullets()
		queue_free()

var has_entered_screen := false


func _on_visible_on_screen_notifier_2d_screen_entered():
	has_entered_screen = true


func _on_visible_on_screen_notifier_2d_screen_exited():
	if has_entered_screen:
		queue_free()
