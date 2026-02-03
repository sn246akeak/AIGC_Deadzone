extends Node2D

const TITLE_PATH := NodePath("UI/Panel/VBoxContainer/Title")
const HINT_PATH := NodePath("UI/Panel/VBoxContainer/Hint")
const BACK_BTN_PATH := NodePath("UI/Panel/VBoxContainer/BackBtn")
const EXTRACT_BTN_PATH := NodePath("UI/Panel/VBoxContainer/ExtractBtn")

@onready var title: Label = get_node_or_null(TITLE_PATH) as Label
@onready var hint: Label = get_node_or_null(HINT_PATH) as Label
@onready var back_btn: Button = get_node_or_null(BACK_BTN_PATH) as Button
@onready var extract_btn: Button = get_node_or_null(EXTRACT_BTN_PATH) as Button

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
	if back_btn == null:
		missing.append("BackBtn")
	if extract_btn == null:
		missing.append("ExtractBtn")
	if missing.is_empty():
		return true
	push_warning("Raid UI nodes missing: %s" % ", ".join(missing))
	return false
