extends HBoxContainer

@onready var option_button: OptionButton = $OptionButton
@onready var head_bob_button: CheckButton = %headBobButton

func _ready() -> void:
	GamePiecesEventBus.connect("combat_type", update_selected)
	head_bob_button.button_pressed = AppSettings.get_head_bob_from_config()
	option_button.selected = AppSettings.get_directional_combat_from_config()

func update_selected(value: int):
	option_button.selected = value
	
func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			AppSettings.set_directional_combat(index)
		1:
			AppSettings.set_directional_combat(index)
		_:
			AppSettings.set_directional_combat(index)


func _on_check_button_toggled(toggled_on: bool) -> void:
	AppSettings.set_head_bob(toggled_on)
