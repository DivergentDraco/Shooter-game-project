class_name Fairy
extends CharacterBody2D

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
var hp = 1

func _physics_process(delta: float) -> void:
	velocity = movement_pattern.get_velocity(delta)
	move_and_slide()

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
		queue_free()

var has_entered_screen := false


func _on_visible_on_screen_notifier_2d_screen_entered():
	has_entered_screen = true


func _on_visible_on_screen_notifier_2d_screen_exited():
	if has_entered_screen:
		queue_free()
