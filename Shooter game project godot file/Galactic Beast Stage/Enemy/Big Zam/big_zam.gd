class_name Big_Zamx
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

@onready var warning = get_tree().current_scene.get_node("Warning/Sprite0001")

var normal_sprite_scale: Vector2
var normal_sprite_modulate: Color

@export var intro_speed: float = 500.0
@export var intro_target_y: float = -300.0
@export var intro_start_y: float = 1000.0

var normal_scale: Vector2
var normal_modulate: Color

const EXPLOSION_SCENE = preload("res://Galactic Beast Stage/Explosion/explosion.tscn")

@export var explosion_count: int = 20
@export var explosion_interval: float = 0.1
@export var explosion_area: Vector2 = Vector2(200, 120)

signal died 
@onready var movement_pattern = $MovementPattern
@onready var screensize  = get_viewport_rect().size
@onready var hit_flash_anim_player = $HitFlashAnimationPlayer
@onready var spawn_points = {
	"spawnpoint_1" : %SpawnPoint,
	"spawnpoint_2" : %SpawnPoint2,
	"spawnpoint_3" : $SpawnPoint3,
	"spawnpoint_4" : $SpawnPoint4,
	"spawnpoint_5" : $SpawnPoint5,
}

signal hp_changed(current_hp: int, max_hp: int)

@export var max_hp: int = 100
var hp: int = 100



func _ready() -> void:
	warning.start()
	
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
			dead_state(delta)
			
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
			for point_name in ["spawnpoint_1", "spawnpoint_2", "spawnpoint_3", "spawnpoint_4","spawnpoint_5"]:
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
			
		BossState.RETURN:
			for point_name in ["spawnpoint_1", "spawnpoint_2", "spawnpoint_3", "spawnpoint_4"]:
				var point = spawn_points[point_name]
				point.active = false
			
		BossState.DEAD:
			stop_all_spawnpoints()
			Spawning.clear_all_bullets()

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
		
var dead_started := false

func dead_state(delta: float) -> void:
	velocity.x = 0
	if not dead_started:
		velocity.y = -30
		dead_started = true

	velocity.y = move_toward(velocity.y, 0.0, 20 * delta)
		

var is_dying := false

func hit(damage: int = 1) -> void:
	if is_dying:
		return

	hp -= damage
	hp_changed.emit(hp, max_hp)

	if hp > 0:
		hit_flash_anim_player.play("hit_flash")
	else:
		is_dying = true
		die()


func die() -> void:
	if state == BossState.DEAD:
		return

	change_state(BossState.DEAD)
	stop_all_spawnpoints()

	set_collision_layer_value(2, false)
	Spawning.clear_all_bullets()

	died.emit(5)

	# Repeated small explosions
	for i in range(explosion_count):
		spawn_random_explosion()
		await get_tree().create_timer(explosion_interval).timeout

	# Final large explosion
	sprite.visible = false
	var final_explosion = EXPLOSION_SCENE.instantiate()
	get_tree().current_scene.add_child(final_explosion)

	final_explosion.global_position = global_position
	final_explosion.scale = Vector2.ONE * 3.0

	# Pixel debris
	var debris = $GPUParticles2D
	debris.reparent(get_tree().current_scene, true)
	debris.restart()
	debris.emitting = true

	# Remove debris after it finishes
	get_tree().create_timer(debris.lifetime + 0.5).timeout.connect(
		debris.queue_free
	)

	# Remove boss, but keep debris and explosions
	queue_free()
	
	
func spawn_random_explosion() -> void:
	var explosion = EXPLOSION_SCENE.instantiate()
	get_parent().add_child(explosion)

	var offset = Vector2(
		randf_range(-explosion_area.x / 2.0, explosion_area.x / 2.0),
		randf_range(-explosion_area.y / 2.0, explosion_area.y / 2.0)
	)

	explosion.global_position = global_position + offset
	explosion.scale = Vector2.ONE * randf_range(0.5, 1.5)

	$ExplodeSFX.play()
	
var has_entered_screen := false

func stop_all_spawnpoints() -> void:
	for point in spawn_points.values():
		point.active = false
		point.set_physics_process(false)

		if point.process_id > 0:
			Spawning.process_kill(point.process_id)


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


func _on_visible_on_screen_notifier_2d_screen_entered():
	has_entered_screen = true


func _on_visible_on_screen_notifier_2d_screen_exited():
	if has_entered_screen:
		queue_free()
