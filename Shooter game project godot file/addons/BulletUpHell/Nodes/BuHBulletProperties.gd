@tool
extends Path2D
class_name BulletPattern

@export_placeholder("ID") var id:String = ""
@export var props:Resource
@export var keep_upon_load:bool = false
@export var show_id_warning:bool = true


func _ready():
	add_to_group("BulletProps")
	if Engine.is_editor_hint():
		generate_bulletprops()
		return
	
	if props.get("a_curve_movement") and props.get("a_curve_movement") > 0:
		assert(curve.get_point_count() > 0, \
			"BulletProperties has no curve. Draw one like you'd draw a Path2D with the BulletPattern node")
		props.curve = curve
	
	Spawning.new_bullet(id, Spawning.sanitize_bulletprops(props, id, self), !show_id_warning)
	#print(dict)
	if not keep_upon_load: queue_free()

func generate_bulletprops():
	if not props: props = Spawning.generate_new_bulletprops()
	else: Spawning.update_custom_bullet_prop_data(props)
