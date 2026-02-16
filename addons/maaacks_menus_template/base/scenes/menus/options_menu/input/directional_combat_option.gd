extends HBoxContainer
@onready var option_button: OptionButton = $OptionButton

func _ready() -> void:
	GamePiecesEventBus.connect("combat_type", update_selected)

func update_selected(value: int):
	option_button.selected = value
	
func _on_option_button_item_selected(index: int) -> void:
	print(index)
	match index:
		0:
			AppSettings.set_directional_combat(index)
		1:
			AppSettings.set_directional_combat(index)
		_:
			AppSettings.set_directional_combat(index)
