extends ActionLeaf

var actor_stored


func tick(actor, blackboard):
	
	actor_stored = actor
	var current_location = actor_stored.global_transform.origin
	var desired_location = actor_stored.navigation_agent.get_next_path_position()
	var new_velocity = (desired_location - current_location).normalized() * actor_stored.SPEED
	
	actor_stored.navigation_agent.set_velocity(new_velocity)
	
	update_target_location(Global.player.global_transform.origin)
	return SUCCESS
	
func update_target_location(target_location):
	var player_position = Vector3(Global.player.global_position.x,Global.player.global_position.y,Global.player.global_position.z)
	actor_stored.navigation_agent.set_target_position(target_location)
	actor_stored.look_at(player_position, Vector3.UP)
	actor_stored.alerted = true


func _on_navigation_agent_3d_target_reached() -> void:
	print("you died!")


func _on_beehave_tree_signal_pass(safe_velocity: Variant) -> void:
	if actor_stored != null:
		actor_stored.velocity = actor_stored.velocity.move_toward(safe_velocity,.15)
		actor_stored.move_and_slide()
