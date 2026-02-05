extends Node2D
class_name RaidPlayer

signal ammo_changed(current: int, reserve: int, mag_size: int)
signal hp_changed(current: int, max_hp: int)
signal reload_state_changed(is_reloading: bool)

@export var move_speed: float = 220.0
@export var fire_cooldown: float = 0.12
@export var reload_time: float = 1.1

const GAME_STATE_PATH := NodePath("/root/Main/GameState")
const BULLET_SCENE := preload("res://scenes/raid/bullet.tscn")

var _mag_size: int = 12
var _ammo_in_mag: int = 12
var _ammo_reserve: int = 36
var _max_hp: int = 100
var _hp: int = 100
var _last_fire_time: float = -10.0
var _reload_remaining: float = 0.0

func _ready() -> void:
	_sync_from_state()
	_emit_status()

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	look_at(get_global_mouse_position())
	_handle_fire_input()
	_handle_reload_input()
	_update_reload(delta)

func _handle_movement(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector.length_squared() > 0.0:
		position += input_vector.normalized() * move_speed * delta

func _handle_fire_input() -> void:
	if not Input.is_action_pressed("shoot"):
		return
	if _reload_remaining > 0.0:
		return
	if _ammo_in_mag <= 0:
		return
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_fire_time < fire_cooldown:
		return
	_last_fire_time = now
	_ammo_in_mag -= 1
	_sync_to_state()
	_emit_ammo()
	_spawn_bullet()

func _handle_reload_input() -> void:
	if not Input.is_action_just_pressed("reload"):
		return
	if _reload_remaining > 0.0:
		return
	if _ammo_in_mag >= _mag_size:
		return
	if _ammo_reserve <= 0:
		return
	_reload_remaining = reload_time
	reload_state_changed.emit(true)

func _update_reload(delta: float) -> void:
	if _reload_remaining <= 0.0:
		return
	_reload_remaining -= delta
	if _reload_remaining > 0.0:
		return
	_reload_remaining = 0.0
	var needed := _mag_size - _ammo_in_mag
	var loaded := min(needed, _ammo_reserve)
	_ammo_in_mag += loaded
	_ammo_reserve -= loaded
	_sync_to_state()
	_emit_ammo()
	reload_state_changed.emit(false)

func _spawn_bullet() -> void:
	if BULLET_SCENE == null:
		return
	var bullet := BULLET_SCENE.instantiate()
	if bullet == null:
		return
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	var direction := (get_global_mouse_position() - global_position).normalized()
	if bullet.has_method("setup"):
		bullet.call("setup", direction)

func _sync_from_state() -> void:
	var gs := get_tree().root.get_node_or_null(GAME_STATE_PATH)
	if gs == null:
		return
	var ps := gs.player_state
	_mag_size = ps.mag_size
	_ammo_in_mag = ps.ammo_in_mag
	_ammo_reserve = ps.ammo_reserve
	_max_hp = ps.max_hp
	_hp = ps.hp

func _sync_to_state() -> void:
	var gs := get_tree().root.get_node_or_null(GAME_STATE_PATH)
	if gs == null:
		return
	var ps := gs.player_state
	ps.mag_size = _mag_size
	ps.ammo_in_mag = _ammo_in_mag
	ps.ammo_reserve = _ammo_reserve
	ps.max_hp = _max_hp
	ps.hp = _hp

func _emit_status() -> void:
	_emit_ammo()
	hp_changed.emit(_hp, _max_hp)

func _emit_ammo() -> void:
	ammo_changed.emit(_ammo_in_mag, _ammo_reserve, _mag_size)
