extends ActionLeaf

var actor_stored

func _ready() -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.wait_time = 10
	timer.timeout.connect(update_target_location.bind(0))
	timer.start()

func tick(actor, blackboard):
	actor_stored = actor
	
	var current_location = actor_stored.global_transform.origin
	var desired_location = actor_stored.navigation_agent.get_next_path_position()
	var new_velocity = (desired_location - current_location).normalized() * actor_stored.SPEED
	
	actor_stored.navigation_agent.set_velocity(new_velocity)

	return SUCCESS
	
func update_target_location(target_location):
	var random_location = Vector3(actor_stored.global_transform.origin.x+randi_range(-50,50),actor_stored.global_transform.origin.y,actor_stored.global_transform.origin.z+randi_range(-50,50))
	actor_stored.navigation_agent.set_target_position(random_location)
	actor_stored.look_at(random_location, Vector3.UP)

func _on_navigation_agent_3d_target_reached() -> void:
	print("you died!")

func _on_beehave_tree_signal_pass(safe_velocity: Variant) -> void:
	if actor_stored != null:
		actor_stored.velocity = actor_stored.velocity.move_toward(safe_velocity,.25)
		actor_stored.move_and_slide()
