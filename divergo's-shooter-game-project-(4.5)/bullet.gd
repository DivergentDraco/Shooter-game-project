extends Area2D

var current_pos = Vector2.ZERO

var player_pos = Vector2.ZERO
var angle = 0.0
var radius = 0.0


var mode = 0 # 0 = straight, 1 = spiral
func start(pos, bullet_mode = 0):
	player_pos = pos
	position = pos
	current_pos = pos
	radius = 0.0
	angle = 0.0
	mode = bullet_mode

func _process(delta):
	if mode == 0:
		straight_bullet(delta)
	else:
		spiral_bullet(delta)

func straight_bullet(delta, vertical_speed = 1000, vertical_accel = 0, orbit_speed = 0, radial_speed = 0.0):
	angle += orbit_speed * delta
	radius += radial_speed * delta
	vertical_speed += vertical_accel * delta
	current_pos.y -= vertical_speed * delta
	var spiral_offset = Vector2(cos(angle), sin(angle)) * radius
	position = current_pos + spiral_offset

func spiral_bullet(delta, vertical_speed = 200, vertical_accel = 300, orbit_speed = 20.0, radial_speed = 60.0):
	angle += orbit_speed * delta
	radius += radial_speed * delta
	vertical_speed += vertical_accel * delta
	current_pos.y -= vertical_speed * delta
	var spiral_offset = Vector2(cos(angle), sin(angle)) * radius
	position = current_pos + spiral_offset

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.explode()
		queue_free()
