extends Resource
class_name PlayerState

@export var max_hp: int = 100
@export var hp: int = 100
@export var money: int = 0
@export var mag_size: int = 12
@export var ammo_in_mag: int = 12
@export var ammo_reserve: int = 36

@export var inventory_ids: Array[String] = []
@export var equipped_weapon_id: String = ""
