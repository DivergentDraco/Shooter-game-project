@tool
extends Path2D
class_name SpawnPattern

@export_placeholder("ID") var id:String = ""
@export var pattern:Pattern
@export var keep_upon_load:bool = false
@export var preview_spawn:bool = false
@export var preview_shoot:bool = false : set = set_pre_shoot
@export var show_id_warning:bool = true

@export_group("Equation")
@export var equation:String
@export var start_sample:Vector2
@export var end_sample:Vector2
@export var sample_step:float
@export_tool_button("Update") var sample = sample_curve
var expr:Expression = Expression.new()
var points:Array[Vector2]

var preview_bullet:BulletProps



func sample_curve():
	var parse_err = expr.parse(equation, ["x", "y"])
	if parse_err != OK:
		push_error(expr.get_error_text())
		return []
	
	points.clear()
	if equation.find("y") == -1:
		# function of x only: y = f(x)
		return sample_function()
	else:
		# implicit equation f(x,y) = 0
		return sample_implicit()

func sample_function():
	# Step 1: pick domain to explore
	# We don't know the function's domain, so take symmetric interval
	var xmin: float = -200.0
	var xmax: float = 200.0
	var raw_points: Array[Vector2] = []

	# Step 2: sample many raw points along x
	var samples = pattern.nbr * 10
	var step = (xmax - xmin) / float(samples)
	for i in range(samples+1):
		var x = xmin + i * step
		var y = expr.execute([x])
		if typeof(y) == TYPE_FLOAT and y == y: # not NaN
			raw_points.append(Vector2(x, y))

	if raw_points.size() < 2:
		return raw_points
	#points = raw_points
	# Step 3: resample evenly by arc length
	return resample_by_arclength(raw_points)


func sample_implicit() -> Array[Vector2]:
	var start = find_start_point(expr)
	if start == Vector2.ZERO:
		push_error("No starting point found on curve. Try adjusting search_xmin/xmax/ymin/ymax or search_step.")
		return []

	var raw_points: Array[Vector2] = [start]
	var p = start
	var tangent = Vector2(1,0)
	var step: float = 2.0
	var max_iter: int = 5000

	for i in range(max_iter):
		# numerical gradient
		var gx = expr.execute([p.x+1, p.y]) - expr.execute([p.x-1, p.y])
		var gy = expr.execute([p.x, p.y+1]) - expr.execute([p.x, p.y-1])
		var grad = Vector2(gx, gy).normalized()
		if grad == Vector2.ZERO: break

		# tangent = perpendicular
		tangent = Vector2(-grad.y, grad.x).normalized()
		p += tangent * step

		# project back to curve
		for j in range(3):
			var fval = expr.execute([p.x, p.y])
			gx = expr.execute([p.x+1, p.y]) - expr.execute([p.x-1, p.y])
			gy = expr.execute([p.x, p.y+1]) - expr.execute([p.x, p.y-1])
			grad = Vector2(gx, gy)
			var denom = grad.length_squared()
			if denom < 0.0001: break
			p -= grad * (fval/denom)
			if abs(expr.execute([p.x, p.y])) < 0.01: break

		if p.distance_to(raw_points.back()) > step*0.5:
			raw_points.append(p)

		# if closed loop, stop early
		if raw_points.size() > 20 and p.distance_to(start) < step*2:
			break

	return resample_by_arclength(raw_points)


func resample_by_arclength(raw_points: Array[Vector2]) -> Array[Vector2]:
	if raw_points.size() < 2:
		return raw_points

	var total_len = 0.0
	for i in range(1, raw_points.size()):
		total_len += raw_points[i].distance_to(raw_points[i-1])

	var segment_len = total_len / float(pattern.nbr)
	var dist_accum = 0.0
	var next_target = 0.0

	for i in range(1, raw_points.size()):
		var a = raw_points[i-1]
		var b = raw_points[i]
		var d = a.distance_to(b)
		while next_target <= dist_accum + d and points.size() < pattern.nbr:
			var t = (next_target - dist_accum) / d
			points.append(a.lerp(b, t))
			next_target += segment_len
		dist_accum += d
	print(points)
	return points

func find_start_point(expr: Expression) -> Vector2:
	var prev_val: float
	var prev_pos: Vector2
	var y:float = start_sample.y
	while y <= end_sample.y:
		var x = start_sample.x
		prev_val = expr.execute([x, y])
		prev_pos = Vector2(x, y)
		x += sample_step
		while x <= end_sample.x:
			var val = expr.execute([x, y])
			if (val == null): 
				x += sample_step
				continue
			# Look for sign change = crossing the curve
			if sign(prev_val) != sign(val):
				# Interpolate between prev_pos and (x,y) for better accuracy
				var t = abs(prev_val) / (abs(prev_val) + abs(val))
				return prev_pos.lerp(Vector2(x, y), t)
			prev_val = val
			prev_pos = Vector2(x, y)
			x += sample_step
		y += sample_step
	return Vector2.ZERO  # nothing found

func _ready():
	if not (!Engine.is_editor_hint() and pattern): return
	if pattern.resource_name in ["PatternCustomShape","PatternCustomPoints"]:
		pattern.shape = curve
	if pattern.resource_name == "PatternCustomShape":
		var follow:PathFollow2D = PathFollow2D.new()
		add_child(follow)
		Spawning.shape_distribute(pattern, curve, follow)
	elif pattern.resource_name == "PatternCustomPoints":
		Spawning.points_distribute(pattern, curve)
	elif pattern.resource_name == "PatternCustomArea":
		Spawning.curve_to_polygon(pattern, curve)
		var function:StringName = "area_distribute" if pattern.grid_spawning == Vector2(0,0) else "grid_distribute"
		Spawning.call(function, pattern)
	
	Spawning.new_pattern(id, Spawning.sanitize_pattern(pattern, self), !show_id_warning)
	if not keep_upon_load: queue_free()

func _process(delta):
	if preview_spawn:# and Engine.is_editor_hint():
		queue_redraw()

func set_pre_shoot(value):
	preview_shoot = value

func _draw():
	for i in points: draw_circle(i, 10, Color.VIOLET)
	if not preview_spawn or pattern == null: return
	if pattern.resource_name in ["PatternCustomShape"]:
		var length = curve.get_baked_length()
		var follow
		if preview_shoot:
			follow = PathFollow2D.new()
			add_child(follow)
			
		draw_circle(pattern.center_pos, 10, Color.YELLOW)
		for b in pattern.nbr:
			var pos_on_curve = length/pattern.nbr*b if pattern.closed_shape \
						else length/(pattern.nbr-1)*b
			var pos = curve.sample_baked(pos_on_curve)
			draw_circle(pos, 10, Color.RED)
			
			if preview_shoot:
				follow.h_offset = pos_on_curve
				draw_line(pos, pos+Vector2(32,0).rotated(follow.rotation-PI/2),Color.YELLOW,3)
		if preview_shoot:
			remove_child(follow)
	elif pattern.resource_name in ["PatternCustomPoints"]:
		draw_circle(pattern.center_pos, 10, Color.YELLOW)
	else:
		for i in pattern.nbr: draw_circle(Spawning.get_spawn_position_from_pattern(pattern, i, 0), 10, Color.RED)
