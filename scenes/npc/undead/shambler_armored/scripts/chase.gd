extends Node

@export var walk_chase_speed: float = 2.0
@export var run_chase_speed: float = 5.0
@export var attack_range: float = 2.5
@export var lose_sight_range: float = 15.0

@export var run_range: float = 10.0
@export var walk_range: float = 5.0
@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

var target
var nav_agent: NavigationAgent3D
var tree_root: AnimationNodeStateMachine

func _on_chase_state_entered() -> void:
	if source_npc.has_shield:
		animation_tree["parameters/walkBlendTree/shieldWalkBlend/blend_position"] = Vector2(0.0,-1.0)
	
	target = source_npc.target
	nav_agent = source_npc.navigation_agent
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/walk", true)
	source_npc.SPEED = walk_chase_speed


func _on_chase_state_exited() -> void:
	animation_tree.set("parameters/conditions/run", false)


func _on_chase_state_physics_processing(delta: float) -> void:
	if not target or not is_instance_valid(target):
		state_chart.send_event("idle")
	animation_tree["parameters/walkBlendTree/walkBlend/blend_position"].y = lerpf(animation_tree["parameters/walkBlendTree/walkBlend/blend_position"].y, 1.0, delta*10)
	animation_tree["parameters/walkBlendTree/walkBlend/blend_position"].x = lerpf(animation_tree["parameters/walkBlendTree/walkBlend/blend_position"].x, 0, delta*10)
	if source_npc.has_shield:
		animation_tree["parameters/walkBlendTree/shieldWalkBlend/blend_position"].y = lerpf(animation_tree["parameters/walkBlendTree/shieldWalkBlend/blend_position"].y, 1.0, delta*10)
		animation_tree["parameters/walkBlendTree/shieldWalkBlend/blend_position"].x = lerpf(animation_tree["parameters/walkBlendTree/shieldWalkBlend/blend_position"].x, 0, delta*10)
	if source_npc.global_position.distance_to(target.global_position) >= run_range:
		animation_tree.set("parameters/conditions/run", true)
		animation_tree.set("parameters/conditions/walk", false)
		source_npc.SPEED = run_chase_speed
	
	elif source_npc.global_position.distance_to(target.global_position) <= walk_range:
		animation_tree.set("parameters/conditions/run", false)
		animation_tree.set("parameters/conditions/walk", true)
		source_npc.SPEED = walk_chase_speed
	
	source_npc.rotation.y = lerp_angle(source_npc.rotation.y, atan2(source_npc.direction.x, source_npc.direction.z),10*delta)
	var current_location = source_npc.global_position
	var desired_location = source_npc.navigation_agent.get_next_path_position()
	var new_velocity = (desired_location - current_location).normalized() * source_npc.SPEED
	source_npc.navigation_agent.set_velocity(new_velocity)
	var target_pos := NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().get_navigation_map(),target.global_position)
	
	
	var is_inside_navmesh: bool = target_pos.distance_to(target.global_position) < .5

	if !is_inside_navmesh:
		state_chart.send_event("back_away")
	else:
		source_npc.navigation_agent.set_target_position(target_pos)
	
	if !source_npc.navigation_agent.is_target_reachable():
		state_chart.send_event("back_away")
	
	if source_npc.global_position.distance_to(target.global_position) <= attack_range && source_npc.right_arm:
		state_chart.send_event("attack")
		
	elif source_npc.global_position.distance_to(target.global_position) <= attack_range && !source_npc.right_arm:
		state_chart.send_event("back_away")
		
	if source_npc.global_position.distance_to(target.global_position) >= lose_sight_range:
		state_chart.send_event("idle")
