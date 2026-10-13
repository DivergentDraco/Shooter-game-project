extends Node2D

@export var speed: float = 300.0
@export var laser_length: float = 100.0
@export var laser_width: float = 14.0
@export var turn_strength: float = 2.0
@export var turn_frequency: float = 2.0
@export var point_spacing: float = 3.0

@onready var head: Marker2D = $Head
@onready var outer: Line2D = $OuterLaser
@onready var inner: Line2D = $InnerLaser

var direction: Vector2 = Vector2.DOWN
var points: PackedVector2Array = []
var elapsed: float = 0.0


func _ready() -> void:
	outer.width = laser_width
	outer.default_color = Color.CYAN
	outer.joint_mode = Line2D.LINE_JOINT_ROUND
	outer.begin_cap_mode = Line2D.LINE_CAP_ROUND
	outer.end_cap_mode = Line2D.LINE_CAP_ROUND

	inner.width = laser_width * 0.3
	inner.default_color = Color.WHITE
	inner.joint_mode = Line2D.LINE_JOINT_ROUND
	inner.begin_cap_mode = Line2D.LINE_CAP_ROUND
	inner.end_cap_mode = Line2D.LINE_CAP_ROUND

	points.append(head.position)


func _physics_process(delta: float) -> void:
	elapsed += delta

	# Rotate movement direction to create curves.
	direction = Vector2(
		sin(elapsed * turn_frequency) * 0.8,
		1.0
	).normalized()

	# Move the head.
	head.position += direction * speed * delta

	# Record positions.
	if points[-1].distance_to(head.position) >= point_spacing:
		points.append(head.position)

	# Keep only the desired laser length.
	trim_laser()

	# Update graphics.
	outer.points = points
	inner.points = points
	
	update_collision()


func trim_laser() -> void:
	var total_length: float = 0.0

	for i in range(points.size() - 1, 0, -1):
		total_length += points[i].distance_to(points[i - 1])

		if total_length > laser_length:
			points = points.slice(i)
			return

@onready var hitbox: Area2D = $Hitbox

var collision_shapes: Array[CollisionShape2D] = []


func update_collision() -> void:
	for shape in collision_shapes:
		shape.queue_free()

	collision_shapes.clear()

	for i in range(points.size() - 1):
		var start = points[i]
		var end = points[i + 1]

		var segment = end - start

		if segment.length() < 0.1:
			continue

		var collision_node = CollisionShape2D.new()
		var capsule = CapsuleShape2D.new()

		capsule.radius = laser_width * 0.5
		capsule.height = segment.length() + laser_width

		collision_node.shape = capsule
		collision_node.position = (start + end) * 0.5
		collision_node.rotation = segment.angle() + PI / 2.0

		hitbox.add_child(collision_node)
		collision_shapes.append(collision_node)
