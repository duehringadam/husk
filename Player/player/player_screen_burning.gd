extends ColorRect


func _on_status_effect_component_status_activated(effects: Array[status_effect]) -> void:
	for i in effects:
		if i.effect_type == Global.STATUS_TYPE.BURNING:
			self.visible = true
