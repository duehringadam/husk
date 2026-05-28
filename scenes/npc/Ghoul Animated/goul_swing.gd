extends Node

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart


func _ready() -> void:
	
	animation_tree["parameters/playback"].connect("state_finished", _anim_finished)
	
func _on_swing_state_entered() -> void:
	source_npc.SPEED = 0
	animation_tree.set("parameters/conditions/chargeRight", false)
	animation_tree.set("parameters/conditions/chargeLeft", false)
	animation_tree.set("parameters/conditions/swing", true)
	

func _on_swing_state_exited() -> void:
	pass


func _on_swing_state_physics_processing(delta: float) -> void:
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
	
			
func _anim_finished(state: StringName):
	if state == "attackLeftEnd":
		animation_tree.set("parameters/conditions/swing", false)
		state_chart.send_event("move")
	if state == "attackRightEnd":
		animation_tree.set("parameters/conditions/swing", false)
		state_chart.send_event("move")
