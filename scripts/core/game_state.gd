extends Node
class_name GameState

# 保险：显式加载 PlayerState 脚本，避免 class_name 还没注册导致找不到类型
const PlayerStateScript = preload("res://scripts/core/player_state.gd")

signal inventory_changed
signal money_changed
signal raid_finished(success: bool, loot_manifest: Array[String])

enum Mode { BASE, RAID }
var mode: Mode = Mode.BASE

var player_state = PlayerStateScript.new()

func reset_run_defaults() -> void:
	if player_state.hp <= 0:
		player_state.hp = player_state.max_hp
	if player_state.ammo_in_mag <= 0 and player_state.ammo_reserve <= 0:
		player_state.ammo_in_mag = player_state.mag_size
		player_state.ammo_reserve = player_state.mag_size * 3

func add_money(amount: int) -> void:
	player_state.money += amount
	money_changed.emit()

func add_item(id: String) -> void:
	player_state.inventory_ids.append(id)
	inventory_changed.emit()

func clear_inventory() -> void:
	player_state.inventory_ids.clear()
	inventory_changed.emit()
