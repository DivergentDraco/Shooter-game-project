@icon("res://addons/BulletUpHell/Sprites/NodeIcons11.png")
extends Trigger
class_name TriggerSignal

@export_placeholder("Signal name") var sig:String = ""

func _init():
	resource_name = "TrigSig"
