extends Node2D

@export var speed: float = 800.0
@export var life_time: float = 1.2

var _direction: Vector2 = Vector2.RIGHT

func setup(direction: Vector2) -> void:
	if direction.length_squared() > 0.0:
		_direction = direction.normalized()
	rotation = _direction.angle()

func _process(delta: float) -> void:
	position += _direction * speed * delta
	life_time -= delta
	if life_time <= 0.0:
		queue_free()
