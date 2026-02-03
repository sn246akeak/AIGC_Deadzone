extends Node

@onready var gs: GameState = $GameState
@onready var host: Node = $SceneHost

const BASE_SCENE := preload("res://scenes/base_shop/baseshop.tscn")
const RAID_SCENE := preload("res://scenes/raid/raid.tscn")

func _ready() -> void:
	_switch_to_base()

func _clear_host() -> void:
	for c in host.get_children():
		c.queue_free()

func _switch_to_base() -> void:
	_clear_host()
	gs.mode = GameState.Mode.BASE
	var base = BASE_SCENE.instantiate()
	host.add_child(base)

func _switch_to_raid() -> void:
	_clear_host()
	gs.mode = GameState.Mode.RAID
	gs.reset_run_defaults()
	var raid = RAID_SCENE.instantiate()
	host.add_child(raid)

func go_to_base() -> void:
	_switch_to_base()

func go_to_raid() -> void:
	_switch_to_raid()
