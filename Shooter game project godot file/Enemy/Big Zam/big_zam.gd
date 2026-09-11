class_name Big_Zam
extends CharacterBody2D

enum BossState {
	INTRO,
	ENTER,
	ATTACK_1,
	ATTACK_2,
	ATTACK_3,
	DEAD,
	RETURN,
}

var original_position: Vector2
var next_state: BossState

@export var state: BossState = BossState.INTRO
@export var move_speed = 100
@export var min_speed = 0
var attack_center: Vector2
var state_time := 0.0

@export var speed: float = 2.0        # How fast the enemy rotates
@export var radius: float = 100     # How big the circle is
@export var center_point: Vector2 = original_position # The middle of the circle

var angle: float = 0.0

@onready var sprite = $AnimatedSprite2D

var normal_sprite_scale: Vector2
var normal_sprite_modulate: Color

@export var intro_speed: float = 500.0
@export var intro_target_y: float = -300.0
@export var intro_start_y: float = 1000.0

var normal_scale: Vector2
var normal_modulate: Color

signal died 
@onready var movement_pattern = $MovementPattern
@onready var screensize  = get_viewport_rect().size
@onready var hit_flash_anim_player = $HitFlashAnimationPlayer
@onready var spawn_points = {
	"spawnpoint_1" : %SpawnPoint,
	"spawnpoint_2" : %SpawnPoint2,
	"spawnpoint_3" : $SpawnPoint3,
	"spawnpoint_4" : $SpawnPoint4,
}

var bullet_scene = preload("res://enemy_bullet.tscn")
var hp = 100

func _ready() -> void:
	normal_scale = scale
	normal_modulate = modulate

	scale = normal_scale * 0.5
	modulate = Color(0.107, 0.107, 0.107, 1.0)

	set_collision_layer_value(2, false)

func _physics_process(delta: float) -> void:
	move_speed = clamp(move_speed, min_speed, 1000)
	state_time += delta

	match state:
		BossState.INTRO:
			intro_state(delta)
		
		BossState.ENTER:
			enter_state(delta)

		BossState.ATTACK_1:
			attack_1(delta)

		BossState.ATTACK_2:
			attack_2(delta)

		BossState.ATTACK_3:
			attack_3(delta)

		BossState.DEAD:
			velocity = Vector2.ZERO
			
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
			for point_name in ["spawnpoint_1", "spawnpoint_2", "spawnpoint_3", "spawnpoint_4"]:
				var point = spawn_points[point_name]
				point.active = true
				point.spawn()

		BossState.ATTACK_2:
			var point = spawn_points["spawnpoint_2"]
			point.active = true
			point.spawn()

		BossState.ATTACK_3:
			var point = spawn_points["spawnpoint_3"]
			point.active = true
			point.spawn()

func intro_state(_delta: float) -> void:
	set_collision_layer_value(2, false)
	
	velocity = Vector2(0.0, -intro_speed)

	if global_position.y <= intro_target_y:
		global_position.y = intro_target_y
		velocity = Vector2.ZERO

		scale = normal_scale
		modulate = normal_modulate

		change_state(BossState.ENTER)
			
func enter_state(_delta: float) -> void:
	set_collision_layer_value(2, false)

	var target_y := 60.0
	var distance: float = target_y - global_position.y

	var eased_speed: float = clampf(
		absf(distance) * 3.0,
		20.0,
		move_speed
	)

	velocity = Vector2(
		0.0,
		signf(distance) * eased_speed
	)

	if absf(distance) < 1.0:
		global_position.y = target_y
		velocity = Vector2.ZERO

		original_position = global_position

		change_state(BossState.ATTACK_1)
		set_collision_layer_value(2, true)

func return_state(_delta: float) -> void:
	var distance: float = global_position.distance_to(original_position)

	if distance < 2.0:
		global_position = original_position
		velocity = Vector2.ZERO
		change_state(next_state)
		return

	var return_speed: float = clampf(distance * 3.0, 30.0, move_speed)

	velocity = global_position.direction_to(original_position) * return_speed

func attack_1(_delta: float) -> void:
	velocity.x = cos(state_time * 2.0) * 60
	velocity.y = cos(state_time * 3) * 20.0
	
	if state_time >= 30.0:
		next_state = BossState.ATTACK_2
		change_state(BossState.RETURN)

func attack_2(delta: float) -> void:
	angle += speed * delta
	
	var offset = Vector2(cos(angle), sin(angle)) * radius
	
	velocity = center_point + offset

	if state_time >= 5.0:
		next_state = BossState.ATTACK_3
		change_state(BossState.RETURN)
		
func attack_3(_delta: float) -> void:
	velocity.x = cos(state_time * 2.0) * 150.0
	velocity.y = 0.0

	if state_time >= 6.0:
		next_state = BossState.ATTACK_1
		change_state(BossState.RETURN)
		
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
