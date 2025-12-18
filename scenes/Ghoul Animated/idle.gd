extends ActionLeaf

var actor_stored
var choose_path: bool = true
var random_pos

func tick(actor: Node, blackboard: Blackboard) -> int:
	if choose_path:	
		actor.animation_tree.set("parameters/conditions/idle", false)
		actor.animation_tree.set("parameters/conditions/walk", true)
		choose_path = false
		actor.SPEED = 1.5
		actor_stored = actor
		var current_location = actor_stored.global_position
		var desired_location = actor_stored.navigation_agent.get_next_path_position()
		var new_velocity = (desired_location - current_location).normalized() * actor_stored.SPEED

		actor_stored.navigation_agent.set_velocity(new_velocity)
		var random_vector3 = Vector3(randf_range(-10,10),randf_range(-10,10),randf_range(-10,10))
		random_pos = NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().get_navigation_map(),random_vector3)
		update_target_location(random_pos)
		
	if blackboard.get_value("aggro") == true:
		return FAILURE

	if actor.global_position.distance_to(random_pos) < 2:
		actor.animation_tree.set("parameters/conditions/walk", false)
		actor.animation_tree.set("parameters/conditions/idle", true)
		actor.SPEED = 0
		choose_path = true
		return SUCCESS
		
	return RUNNING
	
func update_target_location(target_location):
	actor_stored.navigation_agent.set_target_position(target_location)
