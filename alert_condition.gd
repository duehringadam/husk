extends ConditionLeaf

var counter = 0
func tick(actor, blackboard):
	if actor.can_see_player && !actor.chasing:
		counter = clampi(counter+1,0,100)
		
		if counter >= 100:
			blackboard.set_value("player position", Global.player.transform.origin)
			blackboard.set_value("enemy position", actor.global_transform.origin)
			actor.alerted = true
			return SUCCESS
	
	if !actor.can_see_player:
		counter = clampi(counter-1,0,100)
		if counter <= 0:
			actor.alerted = false
			return FAILURE
	
	return FAILURE
