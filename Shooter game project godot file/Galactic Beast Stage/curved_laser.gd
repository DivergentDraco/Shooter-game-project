extends Node2D

@export var pixel_scale: float = 1.0
@export var speed: float = 1500.0
@export var turn_speed: float = 30.0
@export var max_length: float = 180.0
@export var point_spacing: float = 4.0

@onready var head: Marker2D = $Head
@onready var outer: Line2D = $Outer
@onready var core: Line2D = $Core

@export var damage: int = 5
@export var hit_radius: float = 50.0
@export var hit_interval: float = 0.0

var hit_timer: float = 0.0

var target: Node2D
var direction: Vector2 = Vector2.UP
var points: PackedVector2Array = []

@export var homing_delay: float = 0.05

var elapsed: float = 0.0


func _ready() -> void:
	outer.width = 8.0 / pixel_scale
	outer.antialiased = false
	outer.begin_cap_mode = Line2D.LINE_CAP_ROUND
	outer.end_cap_mode = Line2D.LINE_CAP_ROUND

	# Create gradient
	var gradient = Gradient.new()

	gradient.set_color(0, Color(1.0, 0.259, 0.0, 1.0))
	gradient.set_color(1, Color.WHITE)

	gradient.add_point(0.25, Color.ORANGE)
	gradient.add_point(0.5, Color.YELLOW)
	gradient.add_point(0.75, Color(1.0, 0.9, 0.5))

	# Apply gradient to outer laser
	outer.gradient = gradient

	# Inner laser
	core.width = 3.0 / pixel_scale
	core.default_color = Color.WHITE
	core.antialiased = false

	points.append(head.position)


func _physics_process(delta: float) -> void:
	elapsed += delta

	if elapsed >= homing_delay and is_instance_valid(target):
		var target_pos = (
			target.get_global_transform_with_canvas().origin
			/ pixel_scale
		)

		var desired_direction = (
			target_pos - head.global_position
		).normalized()

		var angle_difference = direction.angle_to(desired_direction)

		direction = direction.rotated(
			clamp(
				angle_difference,
				-turn_speed * delta,
				turn_speed * delta
			)
		)

	head.position += direction * speed / pixel_scale * delta

	# Record head positions
	if points[-1].distance_to(head.position) >= point_spacing / pixel_scale:
		points.append(head.position)

	trim_points()

	outer.points = points
	core.points = points
	
	hit_timer -= delta

	if hit_timer <= 0.0:
		check_collision()
		hit_timer = hit_interval


func trim_points() -> void:
	var length: float = 0.0
	var limit = max_length / pixel_scale

	for i in range(points.size() - 1, 0, -1):
		var segment_length = points[i].distance_to(points[i - 1])

		if length + segment_length > limit:
			var remaining = limit - length
			var fraction = remaining / segment_length

			var new_start = points[i].lerp(points[i - 1], fraction)

			points = points.slice(i)
			points[0] = new_start
			return

		length += segment_length

func check_collision() -> void:
	if points.size() < 2:
		return

	var enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in enemies:
		if not enemy is Node2D:
			continue

		if not is_instance_valid(enemy):
			continue

		var enemy_pos: Vector2 = (
			enemy.get_global_transform_with_canvas().origin
			/ pixel_scale
		)

		for i in range(points.size() - 1):
			var start: Vector2 = to_global(points[i])
			var end: Vector2 = to_global(points[i + 1])

			var closest: Vector2 = Geometry2D.get_closest_point_to_segment(
				enemy_pos,
				start,
				end
			)

			var distance: float = enemy_pos.distance_to(closest)

			if distance <= 16.0 / pixel_scale:
				if enemy.has_method("hit"):
					enemy.hit(damage)

				queue_free()
				return


func damage_enemy(enemy: Node2D) -> void:
	if enemy.has_method("hit"):
		enemy.hit()
