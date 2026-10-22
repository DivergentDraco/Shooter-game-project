extends Node
class_name customFunctions

###
## here, you can write custom logic to attach to BuHSpawner.gd
## just create a function, and call then call it from BuHSpawner.gd using CUSTOM.<yourfunction>
## it is better than writing custom logic in BuHSpawner.gd
## because your code would be overwritten at each plugin update
###



func laser_collide(col_pos:Vector2, collider:Node, normal:Vector2, full_length:float, laser:LaserBeam):
	## you can add custom properties to a laser by using metadata
	
	return true


func bullet_collide_body(
	body_rid: RID,
	body: Node,
	body_shape_index: int,
	local_shape_index: int,
	shared_area: Area2D,
	B: Dictionary
) -> bool:

	# Allow screen boundaries to trigger bouncing
	if not body.is_in_group("enemies"):
		return true

	# Only player bullets damage enemies
	if not B["props"].get("groups", []).has("player_bullets"):
		return true

	# Damage enemy
	if body.has_method("hit"):
		body.hit(int(B["props"].get("damage", 1)))

	return true


func bullet_collide_area(
	area_rid: RID,
	area: Area2D,
	area_shape_index: int,
	local_shape_index: int,
	shared_area: Area2D
) -> bool:

	var bullets: Dictionary = shared_area.get_meta("Bullets", {})

	if not bullets.has(local_shape_index):
		return false

	var B: Dictionary = bullets[local_shape_index]

	return damage_enemy(area, B)


func damage_enemy(target: Node, B: Dictionary) -> bool:
	if not is_instance_valid(target):
		return false

	if not target.is_in_group("enemies"):
		return false

	var props: Dictionary = B["props"]

	if not props.get("groups", []).has("player_bullets"):
		return false

	var damage: int = int(props.get("damage", 1))

	if target.has_method("hit"):
		target.hit(damage)
	elif target.has_method("explode"):
		target.explode()
	else:
		return false

	return true
