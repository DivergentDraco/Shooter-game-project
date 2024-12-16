extends Area2D

signal shield_changed
signal died

@export var speed = 150
@export var cooldown = 0.06
@export var bullet_scene : PackedScene
@export var max_shield = 1
var shield = max_shield:
	set = set_shield

var can_shoot = true

@onready var screensize = get_viewport_rect().size
func _ready():
	start()

func start():
	show()
	set_process(true)
	position = Vector2(285, screensize.y - 64)
	shield = max_shield
	$GunCooldown.wait_time = cooldown
	
func _process(delta):
	
	var input = Input.get_vector("left", "right", "up", "down")
	if input.x > 0:
		$Ship.frame = 2
		$Ship/Boosters.animation = "right"
	elif input.x < 0:
		$Ship.frame = 0
		$Ship/Boosters.animation = "left"
	else:
		$Ship.frame = 1
		$Ship/Boosters.animation = "forward"
		
	if Input.is_action_pressed("focus"):
		speed = 75
		$ShiftInd.visible = true
	else:
		speed = 150
		$ShiftInd.visible = false
		
	position += input * speed * delta
	screensize.x = 240
	position = position.clamp(Vector2(8, 8)+Vector2(165,0), screensize - Vector2(8, 8)+Vector2(165,0))
	if Input.is_action_pressed("shoot"):
		shoot()
		
func shoot():
	if not can_shoot:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	$AudioStreamPlayer.play()
	get_tree().root.add_child(b)
	b.start(position + Vector2(0, -8))
	var tween = create_tween().set_parallel(false)
	tween.tween_property($Ship, "position:y", 1, 0.1)
	tween.tween_property($Ship, "position:y", 0, 0.05)

func set_shield(value):
	shield = min(max_shield, value)
	shield_changed.emit(max_shield, shield)
	if shield == 0:
		set_process(false)
		hide()
		#emits died() signal for main.gd to detect
		died.emit()
		
func _on_gun_cooldown_timeout():
	can_shoot = true


func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.explode()
		shield -= max_shield / 2.0
