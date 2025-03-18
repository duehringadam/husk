extends ActionLeaf

var actor_stored
var blackboard_stored

func _ready() -> void:
	pass
	
func tick(actor, blackboard):
	actor_stored = actor
	blackboard_stored = blackboard
	
	var current_location = blackboard.get_value("enemy position")
	var desired_location = actor_stored.navigation_agent.get_next_path_position()
	var new_velocity = (desired_location - current_location).normalized() * actor_stored.SPEED
	actor_stored.navigation_agent.set_velocity(new_velocity)
	update_target_location(blackboard.get_value("player position"))
	actor_stored.move_and_slide()
	return SUCCESS

func update_target_location(target_location):
	var player_position = blackboard_stored.get_value("player position")
	actor_stored.navigation_agent.set_target_position(target_location)
	actor_stored.look_at(player_position, Vector3.UP)



func timer():
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.wait_time = 10
	timer.timeout.connect(update_target_location.bind(0))
	timer.start()


func _on_beehave_tree_signal_pass(safe_velocity: Variant) -> void:
	if actor_stored != null:
		actor_stored.velocity = actor_stored.velocity.move_toward(safe_velocity,.1)
		
