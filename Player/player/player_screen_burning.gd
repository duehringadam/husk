extends ColorRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_status_effect_component_status_activated(effects: Array[status_effect]) -> void:
	if !PlayerConfig.get_config("GameSettings", "ScreenEffects", true): return
	
	for i in effects:
		if i.effect_type == Global.STATUS_TYPE.BURNING:
			self.visible = true
			material["shader_parameter/root_color"] = Color("ffbf4d")
			material["shader_parameter/tip_color"] = Color("ff0800")
			animation_player.play("apply_burn")
		if i.effect_type == Global.STATUS_TYPE.POISONED:
			self.visible = true
			material["shader_parameter/root_color"] = Color("520052")
			material["shader_parameter/tip_color"] = Color("ab00ab")
			animation_player.play("apply_burn")
		if i.effect_type == Global.STATUS_TYPE.BLEEDING:
			self.visible = true
			material["shader_parameter/root_color"] = Color("350000")
			material["shader_parameter/tip_color"] = Color("ff0000")
			animation_player.play("apply_burn")
			
func _on_status_effect_component_status_removed(effects: status_effect) -> void:
		self.visible = false
		animation_player.play("remove_burn")
