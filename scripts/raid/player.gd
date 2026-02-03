extends CharacterBody2D

signal player_died
signal hp_changed(current: int, max_hp: int)
signal ammo_changed(current: int, max_ammo: int)

@export var speed := 240.0
@export var max_hp := 100
@export var max_ammo := 12
@export var fire_rate := 0.15
@export var shot_range := 800.0
@export var damage := 10

var hp := 0
var ammo := 0
var _fire_cooldown := 0.0

func _ready() -> void:
	hp = max_hp
	ammo = max_ammo
	hp_changed.emit(hp, max_hp)
	ammo_changed.emit(ammo, max_ammo)

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	if _fire_cooldown > 0.0:
		_fire_cooldown = max(_fire_cooldown - delta, 0.0)
	if Input.is_action_just_pressed("reload"):
		_reload()
	if Input.is_action_pressed("shoot"):
		_try_fire()

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

func apply_damage(amount: int) -> void:
	if amount <= 0:
		return
	hp = max(hp - amount, 0)
	hp_changed.emit(hp, max_hp)
	if hp == 0:
		player_died.emit()

func _try_fire() -> void:
	if _fire_cooldown > 0.0:
		return
	if ammo <= 0:
		return
	ammo -= 1
	ammo_changed.emit(ammo, max_ammo)
	_fire_cooldown = fire_rate
	_fire_ray()

func _fire_ray() -> void:
	var from := global_position
	var to := from + (get_global_mouse_position() - from).normalized() * shot_range
	var params := PhysicsRayQueryParameters2D.create(from, to)
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.exclude = [self]
	var result := get_world_2d().direct_space_state.intersect_ray(params)
	if result.is_empty():
		return
	var collider := result.get("collider")
	if collider != null and collider.has_method("apply_damage"):
		collider.apply_damage(damage)

func _reload() -> void:
	ammo = max_ammo
	ammo_changed.emit(ammo, max_ammo)
