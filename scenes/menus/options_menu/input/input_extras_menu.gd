extends MarginContainer

@onready var color_rect: ColorRect = $ColorRect
@onready var confirmation_dialog: ConfirmationDialog = $ColorRect/ConfirmationDialog
@onready var check_button: CheckButton = $VBoxContainer/MarginContainer/VBoxContainer/experimental/CheckButton

func _on_experimental_setting_changed(value: Variant) -> void:
	if value:
		color_rect.visible = value
		confirmation_dialog.visible = value
	else:
		color_rect.visible = value
		confirmation_dialog.visible = value
		SignalBus.emit_signal("traditional_combat_toggle", value)


func _on_confirmation_dialog_confirmed() -> void:
	color_rect.visible = false
	SignalBus.emit_signal("traditional_combat_toggle", true)


func _on_confirmation_dialog_canceled() -> void:
	check_button.button_pressed = false
	color_rect.visible = false
	SignalBus.emit_signal("traditional_combat_toggle", false)
