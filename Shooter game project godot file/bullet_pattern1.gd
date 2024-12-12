extends Node2D
@onready var raycast = $RayCast2D
@onready var players = get_tree().get_nodes_in_group("players")
@onready var bullet_spawn = $RayCast2D/SpawnPoint
var velocity = Vector2.ZERO

func _process(_delta):
	if players.size() > 0:
		# Assuming you want to target the first player in the group
		var player = players[0]
		if player != null:
			raycast.look_at(player.global_position)
			
	bullet_spawn.rotation = raycast.rotation
