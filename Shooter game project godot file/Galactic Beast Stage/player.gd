extends CharacterBody2D

#set signal
signal shield_changed()
signal died()
#set variables
@export var speed = 160
@export var cooldown = 0.06
@export var max_shield = 1
@export var bullet_scene : PackedScene

#onready variables and nodes
@onready var ship = $Node2D1/Ship
@onready var shiftind = $Node2D1/ShiftInd

@onready var screensize = get_viewport_rect().size
#adding array variable for storing player positions
var array = PackedVector2Array()

#declare variable shield
var shield = max_shield

#declare variable can_shoot
var can_shoot = true
# bullet mode: 0 = straight, 1 = spiral
var bullet_mode = 0

var laser_side: int = 1

func _ready():
	array.resize(10)
	start()

func start():
	show()
	set_process(true)
	$Node2D1/GunCooldown.wait_time = cooldown
	
func _physics_process(_delta):
	# Move key
	var input = Input.get_vector("left", "right", "up", "down")

	#if input.x > 0:
		#ship.frame = 2
		#boosters.animation = "right"
	#elif input.x < 0:
		#ship.frame = 0
		#boosters.animation = "left"
	#else:
		#ship.frame = 1
		#boosters.animation = "forward"

	# Shift key
	if Input.is_action_pressed("SHIFT"):
		speed = 75
		shiftind.visible = true
	else:
		speed = 300
		shiftind.visible = false

	# Calculate speed and movement
	velocity = input * speed
	move_and_slide()

	#Store positions into arrays
	# print(array)
	if $Node2D1.position != array[0]:
		array.insert(0, $Node2D1.position)
	array.resize(20)
	#Select the 10th position stored in the array
	$Node2D2.position = array[10]

	#Limit the player only inside the box	
	position = position.clamp(Vector2(8, 8), screensize - Vector2(8, 8))

	if Input.is_action_pressed("Z") and can_shoot:
		shoot()

	if Input.is_action_just_pressed("X"):
		#bullet_mode = 1 - bullet_mode # toggle between 0 and 1
		shoot_laser()

func shoot():
	can_shoot = false
	$Node2D1/GunCooldown.start()
	$Node2D1/AudioStreamPlayer.play()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	var bullet_offset = Vector2(3, 0) # half bullet size
	b.start(position + bullet_offset, bullet_mode)
	await get_tree().create_timer(0.045).timeout
	can_shoot = true
	
const HOMING_LASER = preload("res://Galactic Beast Stage/curved_laser.tscn")

@export var laser_spawn_offset = Vector2(12, 20)
@export var laser_launch_angle = 135.0

func fire_homing_laser(enemy: Node2D) -> void:
	var laser = HOMING_LASER.instantiate()

	var laser_world = get_tree().current_scene.get_node(
		"LaserViewport/LaserWorld"
	)

	laser_world.add_child(laser)

	var spawn_offset = Vector2(12 * laser_side, 20)

	var spawn_pos = global_position + spawn_offset
	laser.position = spawn_pos / laser.pixel_scale

	laser.target = enemy

	# Alternate launch directions
	laser.direction = Vector2.UP.rotated(
		deg_to_rad(135.0 * laser_side)
	)

	laser_side *= -1
	
	
@export var laser_cooldown: float = 0.2

var can_fire_laser: bool = true

func shoot_laser() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")

	if enemies.is_empty():
		return

	# Find nearest enemy
	var nearest_enemy: Node2D = null
	var nearest_distance: float = INF

	for enemy in enemies:
		if not enemy is Node2D:
			continue

		var distance = global_position.distance_to(enemy.global_position)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy

	if nearest_enemy == null:
		return

	can_fire_laser = false

	fire_homing_laser(nearest_enemy)

	await get_tree().create_timer(laser_cooldown).timeout

	can_fire_laser = true

func set_shield(value):
	shield = min(max_shield, value)
	shield_changed.emit(max_shield, shield)
	if shield == 0:
		set_process(false)
		hide()
		died.emit()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.hit()
