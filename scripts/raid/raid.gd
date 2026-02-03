extends Node2D

const TITLE_PATH := NodePath("UI/Panel/VBoxContainer/Title")
const HINT_PATH := NodePath("UI/Panel/VBoxContainer/Hint")
const HP_LABEL_PATH := NodePath("UI/Panel/VBoxContainer/HpLabel")
const AMMO_LABEL_PATH := NodePath("UI/Panel/VBoxContainer/AmmoLabel")
const BACK_BTN_PATH := NodePath("UI/Panel/VBoxContainer/BackBtn")
const EXTRACT_BTN_PATH := NodePath("UI/Panel/VBoxContainer/ExtractBtn")

@onready var title: Label = get_node_or_null(TITLE_PATH) as Label
@onready var hint: Label = get_node_or_null(HINT_PATH) as Label
@onready var hp_label: Label = get_node_or_null(HP_LABEL_PATH) as Label
@onready var ammo_label: Label = get_node_or_null(AMMO_LABEL_PATH) as Label
@onready var back_btn: Button = get_node_or_null(BACK_BTN_PATH) as Button
@onready var extract_btn: Button = get_node_or_null(EXTRACT_BTN_PATH) as Button

const MAIN_NODE_PATH := NodePath("Main")
const GAME_STATE_PATH := NodePath("Main/GameState")
const PLAYER_PATH := NodePath("Player")

@onready var player: Node = get_node_or_null(PLAYER_PATH)

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

func _bind_player_signals() -> void:
	if player == null:
		push_warning("Player node not found at %s" % PLAYER_PATH)
		return
	if player.has_signal("hp_changed"):
		player.hp_changed.connect(_update_hp_label)
	if player.has_signal("ammo_changed"):
		player.ammo_changed.connect(_update_ammo_label)
	if player.has_signal("player_died"):
		player.player_died.connect(func():
			if title != null:
				title.text = "玩家已阵亡"
		)

func _refresh_player_ui() -> void:
	if player == null:
		push_warning("Player node not found at %s" % PLAYER_PATH)
		return
	if player.has_method("get"):
		if hp_label != null and player.get("hp") != null and player.get("max_hp") != null:
			_update_hp_label(player.get("hp"), player.get("max_hp"))
		if ammo_label != null and player.get("ammo") != null and player.get("max_ammo") != null:
			_update_ammo_label(player.get("ammo"), player.get("max_ammo"))

func _update_hp_label(current: int, max_hp: int) -> void:
	if hp_label == null:
		return
	hp_label.text = "HP: %d / %d" % [current, max_hp]

func _update_ammo_label(current: int, max_ammo: int) -> void:
	if ammo_label == null:
		return
	ammo_label.text = "Ammo: %d / %d" % [current, max_ammo]

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
