extends Node

@export var patrol_speed: float = 3

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

var is_patrolling := false
var target_pos
var timer

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = 7
	timer.timeout.connect(end_patrol)

func _on_patrolling_state_entered() -> void:
	is_patrolling = false
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/walk", true)
	source_npc.SPEED = patrol_speed
	timer.start()


func _on_patrolling_state_exited() -> void:
	pass # Replace with function body.


func _on_patrolling_state_physics_processing(delta: float) -> void:
	source_npc.rotation.y = lerp_angle(source_npc.rotation.y, atan2(source_npc.direction.x, source_npc.direction.z),10*delta)
	if !is_patrolling:
		var random_patrol_range = randf_range(-5,5)
		var current_location = source_npc.global_position
		var desired_location = source_npc.navigation_agent.get_next_path_position()
		var new_velocity = (desired_location - current_location).normalized() * source_npc.SPEED
		source_npc.navigation_agent.set_velocity(new_velocity)
		var random_vector3 = Vector3(source_npc.global_position.x - random_patrol_range,source_npc.global_position.y - random_patrol_range, source_npc.global_position.z - random_patrol_range)
		var random_pos = NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().get_navigation_map(),random_vector3)
		source_npc.navigation_agent.set_target_position(random_pos)
		if source_npc.navigation_agent.is_target_reachable():
			is_patrolling = true
			
		else:
			is_patrolling = false
			timer.stop()
			state_chart.send_event("idle")
		target_pos = random_pos
	
	if source_npc.global_position.distance_to(target_pos) <= 1:
		is_patrolling = false
		timer.stop()
		state_chart.send_event("idle")
		
		

func end_patrol():
	if !source_npc.navigation_agent.is_navigation_finished():
		is_patrolling = false
		timer.stop()
		state_chart.send_event("idle")
