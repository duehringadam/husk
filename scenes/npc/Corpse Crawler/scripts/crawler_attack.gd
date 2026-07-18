extends Node

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart
@export var lunge_range: float = 3.0

var attack_tracking: bool = false
var attack_counter: int = 1

func _ready() -> void:
	animation_tree["parameters/playback"].connect("state_finished", _state_finished)

func _on_attack_state_entered() -> void:	
	source_npc.target = Global.player
	if source_npc.look_at_modifier:
		source_npc.look_at_modifier.target_node = Global.player.head.get_path()
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/walk", false)
	
	# Either lunge or sting based on distance from target
	if source_npc.global_position.distance_to(source_npc.target.global_position) >= lunge_range:
		animation_tree.set("parameters/conditions/lunge", true)
	else:
		animation_tree.set("parameters/conditions/sting", true)
	
func _on_attack_state_exited() -> void:
	animation_tree.set("parameters/conditions/lunge", false)
	animation_tree.set("parameters/conditions/sting", false)

func _on_attack_state_physics_processing(delta: float) -> void:
	if attack_tracking:
		source_npc.rotation.y = lerp_angle(source_npc.rotation.y, atan2(source_npc.direction.x, source_npc.direction.z),10*delta)
		var current_location = source_npc.global_position
		var desired_location = source_npc.navigation_agent.get_next_path_position()
		var new_velocity = (desired_location - current_location).normalized() * source_npc.SPEED
		source_npc.navigation_agent.set_velocity(new_velocity)
		var random_pos = NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().get_navigation_map(),Global.player.global_position)
		source_npc.navigation_agent.set_target_position(random_pos)

func _state_finished(state: StringName):
	if state == "Lunge":
		state_chart.send_event("back_away")
	if state == "Sting":
		state_chart.send_event("back_away")
