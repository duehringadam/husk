extends ProgressBar

func _on_value_changed(value: float) -> void:
	if value > 0:
		self.visible = true
	if value <= 0:
		self.visible = false

func update_value(amount: float):
	var tween = get_tree().create_tween()
	tween.tween_property(self,"value",amount,.12).set_ease(Tween.EASE_OUT)
