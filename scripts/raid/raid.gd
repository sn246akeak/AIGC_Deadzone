extends Node2D

@onready var title: Label = $UI/Panel/VBoxContainer/Title
@onready var hint: Label = $UI/Panel/VBoxContainer/Hint
@onready var back_btn: Button = $UI/Panel/VBoxContainer/BackBtn
@onready var extract_btn: Button = $UI/Panel/VBoxContainer/ExtractBtn


func _ready() -> void:
	title.text = "Raid (局内) - 占位"
	hint.text = "后面接：玩家/敌人/掉落/撤离点"
	back_btn.text = "返回修理铺"

	back_btn.pressed.connect(func():
		get_tree().root.get_node("Main").go_to_base()
	)
	
	extract_btn.text = "撤离并带出(+1 loot)"
	extract_btn.pressed.connect(func():
		var gs = get_tree().root.get_node("Main/GameState")
		gs.add_money(5)
		gs.add_item("ammo")
		get_tree().root.get_node("Main").go_to_base()
)
