extends Control

@onready var title: Label = $Panel/VBoxContainer/Title
@onready var money_label: Label = $Panel/VBoxContainer/MoneyLabel
@onready var inv_label: Label = $Panel/VBoxContainer/InvLabel
@onready var go_raid_btn: Button = $Panel/VBoxContainer/GoRaidBtn
@onready var add_loot_btn: Button = $Panel/VBoxContainer/AddFakeLootBtn


func _ready() -> void:
	title.text = "Base Shop (修理铺)"
	go_raid_btn.text = "Go Raid"
	add_loot_btn.text = "Add Loot (+10)"
	_refresh()

	add_loot_btn.pressed.connect(func():
		var gs = get_tree().root.get_node("Main/GameState")
		gs.add_money(10)
		gs.add_item("scrap")
		_refresh()
	)

	go_raid_btn.pressed.connect(func():
		get_tree().root.get_node("Main").go_to_raid()
	)

func _refresh() -> void:
	var gs = get_tree().root.get_node("Main/GameState")
	money_label.text = "Money: %d" % gs.player_state.money
	inv_label.text = "Inventory: %s" % str(gs.player_state.inventory_ids)
