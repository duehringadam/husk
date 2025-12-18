extends ActionLeaf



var actor_stored
var chase: bool = true
var random_pos
var attack_once:= true
func tick(actor: Node, blackboard: Blackboard) -> int:
	
	attack_once = true
	actor.SPEED = 3.5
	actor_stored = actor
	var current_location = actor_stored.global_position
	var desired_location = actor_stored.navigation_agent.get_next_path_position()
	var new_velocity = (desired_location - current_location).normalized() * actor_stored.SPEED
	actor_stored.navigation_agent.set_velocity(new_velocity)
	update_target_location(Global.player.global_position)

	if actor.global_position.distance_to(Global.player.global_position) < 3:
		if attack_once:
			attack_once = false
			update_target_location(Global.player.global_position)
			return SUCCESS
		
	return RUNNING
	
func update_target_location(target_location):
	actor_stored.navigation_agent.set_target_position(target_location)
