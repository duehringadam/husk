extends ConditionLeaf

var counter = 0
func tick(actor, blackboard):
	if actor.global_transform.origin.distance_to(Global.player.global_transform.origin) < 10:
		actor.chasing = true
		return SUCCESS
	
	
	return FAILURE
