extends Node

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

func _on_charge_swing_state_entered() -> void:
	if source_npc.left_arm && source_npc.right_arm:
		var rand = randf()
		if rand > 0.5:
			animation_tree.set("parameters/conditions/chargeLeft", true)
		else:
			animation_tree.set("parameters/conditions/chargeRight", true)
			
	if source_npc.right_arm && !source_npc.left_arm:
		animation_tree.set("parameters/conditions/chargeRight", true)
	if !source_npc.right_arm && source_npc.left_arm:
		animation_tree.set("parameters/conditions/chargeLeft", true)


func _on_charge_swing_state_exited() -> void:
	pass # Replace with function body.


func _on_charge_swing_state_physics_processing(delta: float) -> void:
	source_npc.rotation.y = lerp_angle(source_npc.rotation.y, atan2(source_npc.direction.x, source_npc.direction.z),10*delta)
	var current_location = source_npc.global_position
	var desired_location = source_npc.navigation_agent.get_next_path_position()
	var new_velocity = (desired_location - current_location).normalized() * source_npc.SPEED
	source_npc.navigation_agent.set_velocity(new_velocity)
	if source_npc.target:
		var random_pos = NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().get_navigation_map(),source_npc.target.global_position)
		source_npc.navigation_agent.set_target_position(random_pos)
		source_npc.search_position = random_pos
	else:
		var random_pos = NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().get_navigation_map(),Global.player.global_position)
		source_npc.navigation_agent.set_target_position(random_pos)
		source_npc.search_position = random_pos
	
	if source_npc.global_position.distance_to(source_npc.target.global_position) < 1.5:
		source_npc.SPEED = 4
		animation_tree.set("parameters/conditions/chargeRight", false)
		animation_tree.set("parameters/conditions/chargeLeft", false)
		state_chart.send_event("swing")
		
