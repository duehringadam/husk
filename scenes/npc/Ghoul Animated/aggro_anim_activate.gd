extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("aggro") == true && actor.aggro_activate:
		
		AudioManager.play_sound(load("res://sfx/zombie-death-2-95167.mp3"),actor.global_position,10)
		return SUCCESS
	return FAILURE
