extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("aggro") == true:
		return SUCCESS
	return FAILURE
