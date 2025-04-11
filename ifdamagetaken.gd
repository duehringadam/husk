extends ConditionLeaf

var hit: bool = false

func tick(actor,blackboard):
	if hit: 
		hit = false
		return SUCCESS
	return FAILURE

func _on_health_component_health_changed(amount: float, new_value: float) -> void:
	if amount < 0:
		hit = true
