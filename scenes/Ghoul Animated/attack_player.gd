extends ActionLeaf

var actor_stored
var attack_once: bool = true
var random_pos
var player_stored_pos 
func tick(actor: Node, blackboard: Blackboard) -> int:
	if attack_once:
		attack_once = false
		actor.animation_tree.set("parameters/conditions/attack", true)
		actor.animation_tree.set("parameters/sprintAttack/sprintAttack/request", 1)
		actor.SPEED = 5
		actor_stored = actor
		var current_location = actor_stored.global_position
		var desired_location = actor_stored.navigation_agent.get_next_path_position()
		var new_velocity = (desired_location - current_location).normalized() * actor_stored.SPEED
		actor_stored.navigation_agent.set_velocity(new_velocity)
	update_target_location(Global.player.global_position)
	
		
	if !actor.animation_tree.get("parameters/sprintAttack/sprintAttack/active"):
		attack_once = true
		actor.animation_tree.set("parameters/SprintBlend/blend_position",1.0)
		return SUCCESS
	
	return RUNNING
	
func update_target_location(target_location):
	actor_stored.navigation_agent.set_target_position(target_location)
		
