extends Area2D

signal died

var start_pos = Vector2.ZERO
var speed = 100
@export var hp = 26

@onready var screensize  = get_viewport_rect().size
@onready var hit_flash_anim_player = $HitFlashAnimationPlayer

var move = 1
var allow_next_move = true
# Infinity symbol movement variables
var infinity_progress = 0.0
var infinity_duration = 4.0 # seconds per loop (slower)
var infinity_loops = 0
var infinity_center = Vector2.ZERO
var infinity_size = 80.0
# For ease-out downward movement
var move_progress = 0.0
var move_duration = 1.0 # seconds
var move_start_pos = Vector2.ZERO
var move_target_pos = Vector2.ZERO

func _ready():
	position = Vector2(100, -50)
	move_start_pos = position
	move_target_pos = position + Vector2(0, 100) # Move 200px down, adjust as needed

func _process(delta):
	if allow_next_move == true:
		match move:
			1:
				first_move(delta)
			2:
				second_move()
			3:
				third_move()

func first_move(delta):
	if move_progress < move_duration:
		move_progress += delta
		var t = move_progress / move_duration
		# Cubic ease out: 1 - (1-t)^3
		var ease_t = 1.0 - (1.0 - t)**3
		position = move_start_pos.lerp(move_target_pos, ease_t)
		if move_progress >= move_duration:
			position = move_target_pos
			# Setup for infinity movement
			infinity_progress = 0.0
			infinity_loops = 0
			infinity_center = Vector2(100, position.y)
			move = 2 # Advance to next move phase

func second_move():
		# Infinity symbol (lemniscate) movement, loops 2 times
		var loops_required = 2
		var t = (infinity_progress / infinity_duration) * TAU + PI/2 # Start at center
		# Lemniscate of Gerono parametric equations
		var x = infinity_size * cos(t)
		var y = infinity_size * sin(t) * cos(t)
		position = infinity_center + Vector2(x, y)
		infinity_progress += get_process_delta_time()
		if infinity_progress >= infinity_duration:
			infinity_progress = 0.0
			infinity_loops += 1
			if infinity_loops >= loops_required:
				move = 3 # Advance to next move phase

func third_move():
		# Implement the third move behavior here
		pass

func start(pos):
		start_pos = pos
		await get_tree().create_timer(randf_range(0.25, 0.55)).timeout
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
