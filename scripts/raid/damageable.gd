extends Area2D
class_name Damageable

signal died
signal hp_changed(current: int, max_hp: int)

@export var max_hp := 20

var hp := 0

func _ready() -> void:
	hp = max_hp
	hp_changed.emit(hp, max_hp)

func apply_damage(amount: int) -> void:
	if amount <= 0:
		return
	hp = max(hp - amount, 0)
	hp_changed.emit(hp, max_hp)
	if hp == 0:
		died.emit()
