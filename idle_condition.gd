extends ConditionLeaf


func tick(actor, blackboard):
	if !actor.alerted && !actor.chasing:
			return SUCCESS
		
	return FAILURE
