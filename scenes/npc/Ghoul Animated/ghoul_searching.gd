extends Node

@export var patrol_speed: float = 3
@export var source_npc: CharacterBody3D
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

var wait := true

func _on_searching_state_entered() -> void:
	source_npc.SPEED = patrol_speed
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/walk", true)


func _on_searching_state_exited() -> void:
	pass # Replace with function body.


func _on_searching_state_physics_processing(delta: float) -> void:
	source_npc.rotation.y = lerp_angle(source_npc.rotation.y, atan2(source_npc.direction.x, source_npc.direction.z),10*delta)
	
		
	if source_npc.search_position:
		var current_location = source_npc.global_position
		var desired_location = source_npc.navigation_agent.get_next_path_position()
		var new_velocity = (desired_location - current_location).normalized() * source_npc.SPEED
		
		source_npc.navigation_agent.set_velocity(new_velocity)
		var search_pos = NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().get_navigation_map(),source_npc.search_position)
		source_npc.navigation_agent.set_target_position(search_pos)
	
	if source_npc.global_position.distance_to(source_npc.search_position) < 2:
		if wait:
			source_npc.SPEED = 0
			wait = false
			animation_tree.set("parameters/conditions/idle", true)
			animation_tree.set("parameters/conditions/walk", false)
			await get_tree().create_timer(3).timeout
			animation_tree.set("parameters/conditions/idle", false)
			animation_tree.set("parameters/conditions/walk", true)
			source_npc.SPEED = patrol_speed
			var random_patrol_range = randf_range(-5,5)
			var current_location = source_npc.global_position
			var desired_location = source_npc.navigation_agent.get_next_path_position()
			var new_velocity = (desired_location - current_location).normalized() * source_npc.SPEED
			
			source_npc.navigation_agent.set_velocity(new_velocity)
			var random_vector3 = Vector3(source_npc.global_position.x - random_patrol_range,source_npc.global_position.y - random_patrol_range, source_npc.global_position.z - random_patrol_range)
			var random_pos = NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().get_navigation_map(),random_vector3)
			source_npc.navigation_agent.set_target_position(random_pos)
			source_npc.search_position = random_pos
			wait = true
			
