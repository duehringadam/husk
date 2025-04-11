extends ActionLeaf

var actor_stored
var play_anim: bool = true

func tick(actor,blackboard):
	actor.SPEED = 1.5
	if play_anim:
		actor.animation_player.play("metarig|walk",-1,1)
		play_anim = false
	actor_stored = actor
	var current_location = actor_stored.global_position
	var desired_location = actor_stored.navigation_agent.get_next_path_position()
	var new_velocity = (desired_location - current_location).normalized() * actor_stored.SPEED
	
	actor_stored.navigation_agent.set_velocity(new_velocity)
	update_target_location(Global.player.global_position)
	
	if actor.global_position.distance_to(Global.player.global_position) < 1:
		play_anim = true
		return SUCCESS
	return RUNNING
	
func update_target_location(target_location):
	actor_stored.navigation_agent.set_target_position(target_location)
	actor_stored.look_at(target_location)
