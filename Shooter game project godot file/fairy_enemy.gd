extends Area2D

signal died 

var start_pos = Vector2.ZERO
var speed = 100
var bullet_scene = preload("res://enemy_bullet.tscn")
var anchor
var follow_anchor = false
var hp = 3

@onready var screensize  = get_viewport_rect().size
@onready var hit_flash_anim_player = $HitFlashAnimationPlayer

func start(pos):
	follow_anchor = false
	speed = 50
	start_pos = pos
	await get_tree().create_timer(randf_range(0.25, 0.55)).timeout
	var tw = create_tween().set_trans(Tween.TRANS_BACK)
	await tw.finished
	follow_anchor = true
	$ShootTimer.wait_time = randf_range(4, 20)
	$ShootTimer.start()

func explode():
	if hp > 0:
		hp -= 1
		hit_flash_anim_player.play("hit_flash")
	else: 
		speed = 0
		$AnimatedSprite2D.play("explode")
		set_deferred("monitorable", false)
		died.emit(5)
		$ExplodeSFX.play()
		await $AnimatedSprite2D.animation_finished
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
