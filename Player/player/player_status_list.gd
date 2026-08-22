extends VBoxContainer

@onready var bleeding: ProgressBar = %bleeding
@onready var burning: ProgressBar = %burning
@onready var poison: ProgressBar = %poison
@onready var sleep: ProgressBar = %sleep


func _on_status_effect_component_statuses_increased(statuses: Dictionary[int, float]) -> void:
	for i in statuses:
		match i:
			Global.STATUS_TYPE.BURNING:
				burning.update_value(statuses[i])

func _on_status_effect_component_status_removed(effect: status_effect) -> void:
	if effect.effect_type == Global.STATUS_TYPE.BURNING:
		burning.update_value(0)
