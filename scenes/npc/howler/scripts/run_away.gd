extends Node

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

var target

func _on_run_away_state_entered() -> void:
	target = source_npc.target


func _on_run_away_state_exited() -> void:
	pass # Replace with function body.


func _on_run_away_state_physics_processing(delta: float) -> void:
	if not target:
		state_chart.send_event("idle")
	
	if target:
		source_npc.rotation.y = lerp_angle(source_npc.rotation.y, atan2(source_npc.direction.x, source_npc.direction.z),10*delta)
		var to_target = (target.global_position - source_npc.global_position).normalized()
		var retreat_dir = -to_target
		
		var retreat_pos = NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().get_navigation_map(), source_npc.global_position + (retreat_dir))
		source_npc.navigation_agent.set_target_position(retreat_pos)
