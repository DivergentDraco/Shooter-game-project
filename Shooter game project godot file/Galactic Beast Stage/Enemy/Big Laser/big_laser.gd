class_name Big_Laser
extends CharacterBody2D

enum BossState {
	ENTER,
	ATTACK_1,
	DEAD,
}

var original_position: Vector2
var next_state: BossState

@export var state: BossState = BossState.ENTER
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

@export var explosion_count: int = 26
@export var explosion_interval: float = 0.1
@export var explosion_area: Vector2 = Vector2(200, 120)

signal died 
@onready var movement_pattern = $MovementPattern
@onready var screensize  = get_viewport_rect().size
@onready var hit_flash_anim_player = $HitFlashAnimationPlayer
@onready var spawn_points = {
	"spawnpoint_1" : %SpawnPoint1,
}

signal hp_changed(current_hp: int, max_hp: int)

@export var max_hp: int = 100
var hp: int = 100

var laser_process_id: int = -1

func _ready() -> void:
	var point = $SpawnPoint1

	point.process_id = -1
	point.active = false

	hp = max_hp
	set_collision_layer_value(4, false)
	
func _physics_process(delta: float) -> void:
	move_speed = clamp(move_speed, min_speed, 1000)
	state_time += delta

	match state:
		BossState.ENTER:
			enter_state(delta)
		
		BossState.ATTACK_1:
			attack_1(delta)
			
		BossState.DEAD:
			dead_state(delta)

	move_and_slide()
func change_state(new_state: BossState) -> void:
	if state == new_state:
		return

	state = new_state
	state_time = 0.0

	match state:
		BossState.ATTACK_1:
			var point = spawn_points["spawnpoint_1"]
			point.active = true
			point.spawn()

		BossState.DEAD:
			$SpawnPoint1.active = false
			
func enter_state(_delta: float) -> void:
	change_state(BossState.ATTACK_1)
	set_collision_layer_value(4, true)
	
		
func attack_1(_delta: float) -> void:
	velocity.y = 100
		
var dead_started := false

func dead_state(delta: float) -> void:
	velocity.x = 0
	if not dead_started:
		dead_started = true

	velocity.y = move_toward(velocity.y, 400.0, 200.0 * delta)

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

	set_collision_layer_value(4, false)

	died.emit(5)
	
	flicker_sprite()

	# Repeated small explosions
	for i in range(explosion_count):
		spawn_random_explosion()
		await get_tree().create_timer(explosion_interval).timeout
	is_flickering = false
	sprite.visible = false
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

@export var flicker_interval: float = 0.01
var is_flickering: bool = false

func flicker_sprite() -> void:
	is_flickering = true

	while is_flickering:
		sprite.visible = not sprite.visible
		await get_tree().create_timer(flicker_interval).timeout

	sprite.visible = false


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
	if has_entered_screen and not is_dying:
		queue_free()
