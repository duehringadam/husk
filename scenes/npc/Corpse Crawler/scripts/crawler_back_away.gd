extends Node

@export var desired_distance: float = 3
@export var max_back_away_time: float = 2.0

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

@onready var back_away_timer: Timer = %backAwayTimer

var target


func _on_back_away_state_entered() -> void:
	target = source_npc.target
	back_away_timer.wait_time = max_back_away_time
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/walk", true)
	animation_tree.set("parameters/walkBlendSpace/blend_position",Vector2(0.0,-1.0))
	back_away_timer.start()

func _on_back_away_state_exited() -> void:
	back_away_timer.stop()
	pass


func _on_back_away_state_physics_processing(delta: float) -> void:
	var back_up_speed = (animation_tree.get_root_motion_position() / delta).length()
	if not target:
		state_chart.send_event("idle")
	
	var to_target = (target.global_position - source_npc.global_position).normalized()
	var retreat_dir = -to_target
	
	var current_location = source_npc.global_position
	var desired_location = source_npc.navigation_agent.get_next_path_position()
	var new_velocity = (desired_location - current_location).normalized() * back_up_speed
	source_npc.navigation_agent.set_velocity(new_velocity)
	var retreat_pos = NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().get_navigation_map(), source_npc.global_position + (retreat_dir * back_up_speed))
	source_npc.navigation_agent.set_target_position(retreat_pos)
	face_target(delta)
	
	if source_npc.global_position.distance_to(target.global_position) >= desired_distance:
		state_chart.send_event("circle_around")
	
	if back_away_timer.time_left == 0:
		if randf() <= 0.3:
			state_chart.send_event("chase")
		else:
			state_chart.send_event("circle_around")

func face_target(delta: float):
	var target_dir = (target.global_position - source_npc.global_position).normalized()
	source_npc.rotation.y = lerp_angle(source_npc.rotation.y, atan2(target_dir.x, target_dir.z),10*delta)


func _on_approach_detector_rapid_approach_detected() -> void:
	state_chart.send_event("chase")
