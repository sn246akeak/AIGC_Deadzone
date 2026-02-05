extends Control

const TITLE_PATH := NodePath("Panel/VBoxContainer/Title")
const MONEY_LABEL_PATH := NodePath("Panel/VBoxContainer/MoneyLabel")
const INV_LABEL_PATH := NodePath("Panel/VBoxContainer/InvLabel")
const HP_LABEL_PATH := NodePath("Panel/VBoxContainer/HpLabel")
const AMMO_LABEL_PATH := NodePath("Panel/VBoxContainer/AmmoLabel")
const GO_RAID_BTN_PATH := NodePath("Panel/VBoxContainer/GoRaidBtn")
const ADD_LOOT_BTN_PATH := NodePath("Panel/VBoxContainer/AddFakeLootBtn")

@onready var title: Label = get_node_or_null(TITLE_PATH) as Label
@onready var money_label: Label = get_node_or_null(MONEY_LABEL_PATH) as Label
@onready var inv_label: Label = get_node_or_null(INV_LABEL_PATH) as Label
@onready var hp_label: Label = get_node_or_null(HP_LABEL_PATH) as Label
@onready var ammo_label: Label = get_node_or_null(AMMO_LABEL_PATH) as Label
@onready var go_raid_btn: Button = get_node_or_null(GO_RAID_BTN_PATH) as Button
@onready var add_loot_btn: Button = get_node_or_null(ADD_LOOT_BTN_PATH) as Button

const MAIN_NODE_PATH := NodePath("Main")
const GAME_STATE_PATH := NodePath("Main/GameState")

func _ready() -> void:
	if not _validate_ui():
		return
	title.text = "Base Shop (修理铺)"
	go_raid_btn.text = "Go Raid"
	add_loot_btn.text = "Add Loot (+10)"
	_refresh()

	add_loot_btn.pressed.connect(func():
		var gs := _get_game_state()
		if gs == null:
			return
		gs.add_money(10)
		gs.add_item("scrap")
		_refresh()
	)

	go_raid_btn.pressed.connect(func():
		var main := _get_main()
		if main == null:
			return
		main.go_to_raid()
	)

func _refresh() -> void:
	if money_label == null or inv_label == null or hp_label == null or ammo_label == null:
		return
	var gs := _get_game_state()
	if gs == null:
		return
	var ps := gs.player_state
	money_label.text = "Money: %d" % ps.money
	inv_label.text = "Inventory: %s" % str(ps.inventory_ids)
	hp_label.text = "HP: %d/%d" % [ps.hp, ps.max_hp]
	ammo_label.text = "Ammo: %d/%d | Reserve: %d" % [ps.ammo_in_mag, ps.mag_size, ps.ammo_reserve]

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
	if money_label == null:
		missing.append("MoneyLabel")
	if inv_label == null:
		missing.append("InvLabel")
	if hp_label == null:
		missing.append("HpLabel")
	if ammo_label == null:
		missing.append("AmmoLabel")
	if go_raid_btn == null:
		missing.append("GoRaidBtn")
	if add_loot_btn == null:
		missing.append("AddFakeLootBtn")
	if missing.is_empty():
		return true
	push_warning("BaseShop UI nodes missing: %s" % ", ".join(missing))
	return false
