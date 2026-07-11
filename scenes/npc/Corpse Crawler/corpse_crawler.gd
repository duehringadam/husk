extends  npc

func _physics_process(delta: float) -> void:
	#var curr_rot = (animation_tree.get_root_motion_rotation_accumulator().inverse() * get_quaternion())
	#var root_rotation = animation_tree.get_root_motion_rotation()
	direction = navigation_agent.get_next_path_position() - global_transform.origin
	direction = direction.normalized()
	velocity = (animation_tree.get_root_motion_position() / delta).length() * direction
	if !is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity")
	move_and_slide()
