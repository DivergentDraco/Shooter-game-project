extends Node

var stage_time:= 0.0
var wave_index := 0
var wave_active := false
var pending_spawns := 0

var wave_transitioning := false

var stage_started := false

@onready var cloud = get_tree().current_scene.get_node("Warning/Sprite0002")
@onready var bg = $"../Background"

var wave_order = [
	"wave_1",
	"wave_2",
	"wave_5",
	"wave_7",
	"wave_4",
	"wave_3",
	"wave_6",
	"wave_8",
	"wave_9",
]

func hide_bg_delayed() -> void:
	await get_tree().create_timer(0.7).timeout
	bg.visible = false

func _process(_delta: float) -> void:
	if not stage_started:
		return
	
	if wave_transitioning:
		return
	
	if not wave_active:
		start_next_wave()
		return

	var enemies_container = get_tree().current_scene.get_node("Enemies")

	if enemies_container.get_child_count() == 0 and pending_spawns == 0:
		wave_active = false
		
func start_stage() -> void:
	if stage_started:
		return

	stage_started = true
	print("Stage started")
		
func start_next_wave() -> void:
	if wave_index >= wave_order.size():
		return
	
	wave_transitioning = true
	
	var wave_name = wave_order[wave_index]

	var anim = $"../AnimationPlayer"
	match wave_name:
		"wave_1":
			anim.speed_scale = 1.0

		"wave_2":
			anim.speed_scale = 1.0

		"wave_3":
			anim.speed_scale = 2.0

		"wave_4":
			anim.speed_scale = 2

		"wave_5":
			anim.speed_scale = 1

		"wave_6":
			anim.speed_scale = 2
			
		"wave_7":
			anim.speed_scale = 1
			
		"wave_8":
			anim.speed_scale = 2
			
		"wave_9":
			anim.speed_scale = 2
			cloud.start()
			hide_bg_delayed()
			
		"wave_10":
			anim.speed_scale = 0.5
			await get_tree().create_timer(1.0).timeout

		_:
			anim.speed_scale = 1.0

	spawn_wave(wave_name)

	wave_index += 1
	wave_active = true
	wave_transitioning = false

const FAIRY = preload("res://Enemy/Fairy Enemy/fairy_enemy.tscn")
const MAID = preload("res://Enemy/Maid Enemy/maid_enemy.tscn")
const UFO = preload("res://Enemy/UFO/ufo.tscn")
const ZOOMER = preload("res://Enemy/Zoomer/zoomer.tscn")
const BIG_ZAM = preload("res://Enemy/Big Zam/big_zam.tscn")

var waves = {
	"wave_1": [
		#{"enemy": FAIRY, 
		#"pos": Vector2(50, 100), 
		#"movement_pattern": MovementPattern.Pattern.NO_PATTERN},
		{"enemy": FAIRY, 
		"pos": Vector2(50, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":0,
		"spawnpoint": 1,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(50, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":0.2,
		"spawnpoint": 1,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(50, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":0.4,
		"spawnpoint": 1,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(50, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":0.6,
		"spawnpoint": 1,
		},
		
		
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":1,
		"spawnpoint": 1,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":1.2,
		"spawnpoint": 1,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":1.4,
		"spawnpoint": 1,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":1.6,
		"spawnpoint": 1,
		},
		
		{"enemy": FAIRY, 
		"pos": Vector2(50, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 400,
		"acceleration": -400,
		"delay":2.5,
		"spawnpoint": 2,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(100, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 400,
		"acceleration": -400,
		"delay":2.5,
		"spawnpoint": 2,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 400,
		"acceleration": -400,
		"delay":2.5,
		"spawnpoint": 2,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(200, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 400,
		"acceleration": -400,
		"delay":2.5,
		"spawnpoint": 2,
		},
		
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.SINE, 
		"speed": 150,
		"acceleration": 0,
		"delay":4,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.SINE, 
		"speed": 150,
		"acceleration": 0,
		"delay":4.2,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.SINE, 
		"speed": 150,
		"acceleration": 0,
		"delay":4.4,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.SINE, 
		"speed": 150,
		"acceleration": 0,
		"delay":4.6,
		},
		
#		V shaped
		{"enemy": FAIRY, 
		"pos": Vector2(50, -10), 
		"movement_pattern": MovementPattern.Pattern.SINE, 
		"speed": 150,
		"acceleration": 0,
		"delay":5,
		
		},
		{"enemy": FAIRY, 
		"pos": Vector2(50, -10), 
		"movement_pattern": MovementPattern.Pattern.SINE, 
		"speed": 150,
		"acceleration": 0,
		"delay":5.2,
		
		},
		{"enemy": FAIRY, 
		"pos": Vector2(50, -10), 
		"movement_pattern": MovementPattern.Pattern.SINE, 
		"speed": 150,
		"acceleration": 0,
		"delay":5.4,
		
		},
		{"enemy": FAIRY, 
		"pos": Vector2(50, -10), 
		"movement_pattern": MovementPattern.Pattern.SINE, 
		"speed": 150,
		"acceleration": 0,
		"delay":5.6,
		
		},
		#{"enemy": FAIRY, "pos": Vector2(100, 100), "movement_pattern": MovementPattern.Pattern.SINE},
		#{"enemy": FAIRY, "pos": Vector2(150, 100), "movement_pattern": MovementPattern.Pattern.DIAGONAL_LEFT},
	],
	"wave_2": [
		{"enemy": FAIRY, 
		"pos": Vector2(50, -50), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 150,
		"acceleration": 50,
		"delay":0,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(70, -30), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 150,
		"acceleration": 50,
		"delay":0,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(90, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 150,
		"acceleration": 50,
		"delay":0,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(110, -30), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 150,
		"acceleration": 50,
		"delay":0,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(130, -50), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 150,
		"acceleration": 50,
		"delay":0,
		},
		
		{"enemy": FAIRY, 
		"pos": Vector2(-10, 50), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"direction": Vector2(1, 0),
		"min_speed": 80,
		"speed": 200,
		"acceleration": -300,
		"delay":1,
		"spawnpoint": 3,
		},
		
		{"enemy": FAIRY, 
		"pos": Vector2(250, 50), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"direction": Vector2(-1, 0),
		"min_speed": 80,
		"speed": 200,
		"acceleration": -300,
		"delay":1,
		"spawnpoint": 3,
		},
		
		{"enemy": FAIRY, 
		"pos": Vector2(-10, 50), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"direction": Vector2(1, 0),
		"min_speed": 80,
		"speed": 200,
		"acceleration": -300,
		"delay":1.3,
		"spawnpoint": 3,
		},
		
		{"enemy": FAIRY, 
		"pos": Vector2(250, 50), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"direction": Vector2(-1, 0),
		"min_speed": 80,
		"speed": 200,
		"acceleration": -300,
		"delay":1.3,
		"spawnpoint": 3,
		},
	],
	
	"wave_3": [
		{"enemy": MAID, 
		"pos": Vector2(122, 0), 
		#"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		#"speed": 250,
		#"acceleration": -300,
		#"min_speed": 0,
		#"delay":0,
		},
	],
	"wave_4": [
		{"enemy": BIG_ZAM, 
		"pos": Vector2(122, 500), 
		#"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		#"speed": 250,
		#"acceleration": -300,
		#"min_speed": 0,
		#"delay":0,
		},
	],
	"wave_5": [
		{"enemy": FAIRY, 
		"pos": Vector2(80, -10), 
		"movement_pattern": MovementPattern.Pattern.SWERVE_LEFT,
		"delay":0,
		"spawnpoint": 1,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(80, -10), 
		"movement_pattern": MovementPattern.Pattern.SWERVE_LEFT,
		"delay":0.3,
		"spawnpoint": 1,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(80, -10), 
		"movement_pattern": MovementPattern.Pattern.SWERVE_LEFT,
		"delay":0.6,
		"spawnpoint": 1,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(160, -10), 
		"movement_pattern": MovementPattern.Pattern.SWERVE_RIGHT,
		"delay":1.2,
		"spawnpoint": 1,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(160, -10), 
		"movement_pattern": MovementPattern.Pattern.SWERVE_RIGHT,
		"delay":1.5,
		"spawnpoint": 1,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(160, -10), 
		"movement_pattern": MovementPattern.Pattern.SWERVE_RIGHT,
		"delay":1.8,
		"spawnpoint": 1,
		},
	],
	"wave_6": [
		{"enemy": UFO, 
		"pos": Vector2(120, 100), 
		},
		{"enemy": UFO, 
		"pos": Vector2(90, 100), 
		},
		{"enemy": UFO, 
		"pos": Vector2(150, 100), 
		},
	],
	
	"wave_7": [
		{"enemy": ZOOMER, 
		"pos": Vector2(30, -10), 
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(60, -10), 
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(90, -10), 
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(120, -10), 
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(150, -10), 
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(180, -10), 
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(210, -10), 
		},
	],
	
	"wave_8": [
		{"enemy": ZOOMER, 
		"pos": Vector2(60, -10), 
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(120, -10), 
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(180, -10), 
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(60, -10), 
		"delay": 0.3,
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(120, -10), 
		"delay": 0.3,
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(180, -10), 
		"delay": 0.3,
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(60, -10), 
		"delay": 0.6,
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(120, -10), 
		"delay": 0.6,
		},
		{"enemy": ZOOMER, 
		"pos": Vector2(180, -10), 
		"delay": 0.6,
		},
	],
	
	"wave_9": [
	],
}
func spawn_wave(wave_name: String) -> void:
	if not waves.has(wave_name):
		print("Wave does not exists: ", wave_name)
		return
		
	var wave = waves[wave_name]

	pending_spawns = wave.size()

	for entry in wave:
		spawn_enemy_delayed(entry)
	
		
func spawn_enemy_delayed(entry: Dictionary) -> void:
	var delay: float = entry.get("delay", 0.0)

	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

	spawn_enemy(entry)
	
	pending_spawns -= 1
	
func spawn_enemy(entry: Dictionary) -> void:
	var enemies_container = get_tree().current_scene.get_node("Enemies")

	var enemy = entry.enemy.instantiate()
	
	enemy.position = entry.pos

	if entry.has("spawnpoint"):
		enemy.set_spawnpoint(entry.spawnpoint)

	enemies_container.add_child(enemy)
	#enemy.global_position = entry.pos

	if entry.has("movement_pattern"):
		enemy.set_movement_pattern(entry.movement_pattern)

	if entry.has("speed"):
		enemy.set_movement_speed(entry.speed)

	if entry.has("acceleration"):
		enemy.set_acceleration(entry.acceleration)
		
	if entry.has("min_speed"):
		enemy.set_min_speed(entry.min_speed)

	if entry.has("max_speed"):
		enemy.set_max_speed(entry.max_speed)
	
	if entry.has("direction"):
		enemy.set_movement_direction(entry.direction)
