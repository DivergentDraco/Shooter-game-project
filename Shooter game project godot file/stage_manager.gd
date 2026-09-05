extends Node

var stage_time:= 0.0
var wave_index := 0
var wave_active := false
var pending_spawns := 0

var stage_started := false

var wave_order = [
	"wave_1",
	"wave_2",
	"wave_1",
]

func _process(_delta: float) -> void:
	if not stage_started:
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
		#print("All waves cleared!")
		return

	var wave_name = wave_order[wave_index]

	spawn_wave(wave_name)

	wave_index += 1
	wave_active = true

const FAIRY = preload("res://Enemy/Fairy Enemy/fairy_enemy.tscn")

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
		},
		{"enemy": FAIRY, 
		"pos": Vector2(50, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":0.2,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(50, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":0.4,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(50, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":0.6,
		},
		
		
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":1,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":1.2,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":1.4,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 10,
		"acceleration": 150,
		"delay":1.6,
		},
		
		{"enemy": FAIRY, 
		"pos": Vector2(50, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 400,
		"acceleration": -400,
		"delay":2.5,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(100, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 400,
		"acceleration": -400,
		"delay":2.5,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(150, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 400,
		"acceleration": -400,
		"delay":2.5,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(200, -10), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"speed": 400,
		"acceleration": -400,
		"delay":2.5,
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
		},
		
		{"enemy": FAIRY, 
		"pos": Vector2(250, 50), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"direction": Vector2(-1, 0),
		"min_speed": 80,
		"speed": 200,
		"acceleration": -300,
		"delay":1,
		},
		
		{"enemy": FAIRY, 
		"pos": Vector2(-10, 50), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"direction": Vector2(1, 0),
		"min_speed": 80,
		"speed": 200,
		"acceleration": -300,
		"delay":1.3,
		},
		
		{"enemy": FAIRY, 
		"pos": Vector2(250, 50), 
		"movement_pattern": MovementPattern.Pattern.STRAIGHT, 
		"direction": Vector2(-1, 0),
		"min_speed": 80,
		"speed": 200,
		"acceleration": -300,
		"delay":1.3,
		},
	],
	
	"wave_3": [
		{"enemy": FAIRY, 
		"pos": Vector2(150, 50), 
		"movement_pattern": MovementPattern.Pattern.NO_PATTERN, 
		"speed": 150,
		"acceleration": 50,
		"delay":0,
		},
		{"enemy": FAIRY, 
		"pos": Vector2(120, 50), 
		"movement_pattern": MovementPattern.Pattern.NO_PATTERN, 
		"speed": 150,
		"acceleration": 50,
		"delay":0,
		},
	]
	
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

	enemies_container.add_child(enemy)
	enemy.global_position = entry.pos

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

func spawn_line_wave():
	for i in range(5):
		var enemy = FAIRY.instantiate()

		enemy.global_position = Vector2(
			80 + i * 70,
			-50
		)

		$Enemies.add_child(enemy)
		
func spawn_v_wave():
	var positions = [
		Vector2(100,-40),
		Vector2(150,-70),
		Vector2(200,-40),
	]
	for pos in positions:
		var enemy = FAIRY.instantiate()
		$Enemies.add_child(enemy)
		enemy.global_position = pos
