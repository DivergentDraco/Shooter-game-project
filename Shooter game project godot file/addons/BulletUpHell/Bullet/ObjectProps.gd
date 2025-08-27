@tool
@icon("res://addons/BulletUpHell/Sprites/NodeIcons18.png")
extends Resource
class_name ObjectProps

@export_placeholder("Instance ID") var instance_id:String
@export var fixed_rotation:bool = true
@export var angle:float
@export var groups:PackedStringArray = []
@export var overwrite_groups:bool = false
@export var temp_count:int = 0

@export_group("Triggers")
@export_placeholder("Container ID") var trigger_container:String
@export var trigger_wait_for_shot = true
#@export var r_trigger_choice:String
