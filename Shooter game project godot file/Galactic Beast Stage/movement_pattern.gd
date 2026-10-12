class_name MovementPattern
extends Node

enum Pattern {
	NO_PATTERN,
	STRAIGHT,
	SINE,
	DIAGONAL_LEFT,
	DIAGONAL_RIGHT,
	SWERVE_LEFT,
	SWERVE_RIGHT,
}

@export var pattern = Pattern.STRAIGHT

@export var speed: float = 100.0
@export var acceleration: float = 0.0
@export var min_speed: float = -300.0
@export var max_speed: float = 300.0
@export var direction: Vector2 = Vector2.DOWN

@export var sine_strength: float = 150.0
@export var sine_frequency: float = 5

var age := 0.0


func get_velocity(delta: float) -> Vector2:
	age += delta

	speed += acceleration * delta
	speed = clamp(speed, min_speed, max_speed)

	match pattern:
		Pattern.NO_PATTERN:
			return Vector2.ZERO
		Pattern.STRAIGHT:
			return direction.normalized() * speed
		Pattern.SINE:
			return Vector2(
				sin(age * sine_frequency) * sine_strength,
				speed
			)
		Pattern.DIAGONAL_LEFT:
			return Vector2(-100.0, speed)
		Pattern.DIAGONAL_RIGHT:
			return Vector2(100.0, speed)
		Pattern.SWERVE_LEFT:
			return Vector2(
				-age * speed, 100.0)
		Pattern.SWERVE_RIGHT:
			return Vector2(
				age * speed, 100.0)

	return Vector2.ZERO
