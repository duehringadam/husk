extends ColorRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_status_effect_component_status_activated(effects: Array[status_effect]) -> void:
	for i in effects:
		if i.effect_type == Global.STATUS_TYPE.BURNING:
			self.visible = true
			animation_player.play("apply_burn")
			
func _on_status_effect_component_status_removed(effects: status_effect) -> void:
	if effects.effect_type == Global.STATUS_TYPE.BURNING:
			self.visible = false
			animation_player.play("remove_burn")
