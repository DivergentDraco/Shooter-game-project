@tool
@icon("res://addons/BulletUpHell/Sprites/NodeIcons16.png")
extends Pattern
class_name PatternCustomPoints

enum ANGLE_TYPE{FromTangeant,FromCenter,Custom}
var shape:Curve2D
@export var calculate_angles:ANGLE_TYPE = ANGLE_TYPE.FromTangeant
@export var angles:Array = []
var pos:Array = []
@export var center_pos:Vector2
@export var reversed_angle:bool = false
@export_range(0, 9999, 1, "suffix:th bullet") var center:int = 0

#@export_group("Shooting")
enum SYMTYPE{ClosedShape,Line}
@export var symmetric:bool = false
@export var symmetry_type:SYMTYPE = SYMTYPE.ClosedShape



func _init():
	resource_name = "PatternCustomPoints"
