extends Node2D

const TITLE_PATH := NodePath("UI/Panel/VBoxContainer/Title")
const HINT_PATH := NodePath("UI/Panel/VBoxContainer/Hint")
const HP_LABEL_PATH := NodePath("UI/Panel/VBoxContainer/HpLabel")
const AMMO_LABEL_PATH := NodePath("UI/Panel/VBoxContainer/AmmoLabel")
const BACK_BTN_PATH := NodePath("UI/Panel/VBoxContainer/BackBtn")
const EXTRACT_BTN_PATH := NodePath("UI/Panel/VBoxContainer/ExtractBtn")
const PLAYER_PATH := NodePath("Player")

@onready var title: Label = get_node_or_null(TITLE_PATH) as Label
@onready var hint: Label = get_node_or_null(HINT_PATH) as Label
@onready var hp_label: Label = get_node_or_null(HP_LABEL_PATH) as Label
@onready var ammo_label: Label = get_node_or_null(AMMO_LABEL_PATH) as Label
@onready var back_btn: Button = get_node_or_null(BACK_BTN_PATH) as Button
@onready var extract_btn: Button = get_node_or_null(EXTRACT_BTN_PATH) as Button
@onready var player: RaidPlayer = get_node_or_null(PLAYER_PATH) as RaidPlayer

const MAIN_NODE_PATH := NodePath("Main")
const GAME_STATE_PATH := NodePath("Main/GameState")

func _ready() -> void:
	if not _validate_ui():
		return
	title.text = "Raid (局内) - 占位"
	hint.text = "WASD移动 / 鼠标瞄准 / 左键射击 / R换弹"
	back_btn.text = "返回修理铺"
	_refresh_player_ui()
	_bind_player_signals()

	back_btn.pressed.connect(func():
		var main := _get_main()
		if main == null:
			return
		main.go_to_base()
	)
	
	extract_btn.text = "撤离并带出(+1 loot)"
	extract_btn.pressed.connect(func():
		var gs := _get_game_state()
		if gs == null:
			return
		gs.add_money(5)
		gs.add_item("ammo")
		var main := _get_main()
		if main == null:
			return
		main.go_to_base()
	)

func _refresh_player_ui() -> void:
	if hp_label == null or ammo_label == null:
		return
	var gs := _get_game_state()
	if gs == null:
		return
	var ps := gs.player_state
	hp_label.text = "HP: %d/%d" % [ps.hp, ps.max_hp]
	ammo_label.text = "Ammo: %d/%d | Reserve: %d" % [ps.ammo_in_mag, ps.mag_size, ps.ammo_reserve]

func _bind_player_signals() -> void:
	if player == null:
		push_warning("Raid player node missing at %s" % PLAYER_PATH)
		return
	player.ammo_changed.connect(func(current: int, reserve: int, mag_size: int):
		if ammo_label != null:
			ammo_label.text = "Ammo: %d/%d | Reserve: %d" % [current, mag_size, reserve]
	)
	player.hp_changed.connect(func(current: int, max_hp: int):
		if hp_label != null:
			hp_label.text = "HP: %d/%d" % [current, max_hp]
	)

func _get_main() -> Node:
	var main := get_tree().root.get_node_or_null(MAIN_NODE_PATH)
	if main == null:
		push_warning("Main node not found at %s" % MAIN_NODE_PATH)
	return main

func _get_game_state() -> GameState:
	var gs := get_tree().root.get_node_or_null(GAME_STATE_PATH)
	if gs == null:
		push_warning("GameState node not found at %s" % GAME_STATE_PATH)
	return gs

func _validate_ui() -> bool:
	var missing := PackedStringArray()
	if title == null:
		missing.append("Title")
	if hint == null:
		missing.append("Hint")
	if hp_label == null:
		missing.append("HpLabel")
	if ammo_label == null:
		missing.append("AmmoLabel")
	if back_btn == null:
		missing.append("BackBtn")
	if extract_btn == null:
		missing.append("ExtractBtn")
	if missing.is_empty():
		return true
	push_warning("Raid UI nodes missing: %s" % ", ".join(missing))
	return false
