extends ConditionLeaf


func tick(actor,blackboard):
	if actor.global_position.distance_to(Global.player.global_position) < 2:
		return SUCCESS
	else:
		return FAILURE
