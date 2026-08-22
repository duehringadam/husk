extends ColorRect

signal drop_amount(value: int)

@onready var drop_amount_slider: HSlider = %dropAmountSlider
@onready var slider_value: Label = %sliderValue

func show_drop_popup():
	self.show()
	drop_amount_slider.grab_focus()

func hide_drop_popup():
	self.hide()

func update_slider_amounts(maximum_value: int):
	drop_amount_slider.max_value = maximum_value

func _on_drop_amount_slider_value_changed(value: float) -> void:
	slider_value.text = str(int(value))

func _on_confirm_pressed() -> void:
	drop_amount.emit(drop_amount_slider.value)
	hide_drop_popup()

func _on_cancel_pressed() -> void:
	hide_drop_popup()
