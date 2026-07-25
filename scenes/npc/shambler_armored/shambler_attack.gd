extends Node

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

var attack_tracking: bool = false
var attack_counter: int = 1

func _ready() -> void:
	animation_tree["parameters/playback"].connect("state_finished", _anim_finished)

func _on_attack_state_entered() -> void:
	attack_counter = 1
	source_npc.target = Global.player
	if source_npc.look_at_modifier:
		source_npc.look_at_modifier.target_node = Global.player.head.get_path()
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/walk", false)
	
	source_npc.SPEED = 4
	
	if randf() > 0.4:
		animation_tree.set("parameters/conditions/attack", true)
	else:
		animation_tree.set("parameters/conditions/combo_attack", true)
	
func _on_attack_state_exited() -> void:
	animation_tree.set("parameters/conditions/combo_attack", false)
	animation_tree.set("parameters/conditions/attack", false)
	source_npc.activate_mainhand_weapon(false)

func _on_attack_state_physics_processing(delta: float) -> void:
	if attack_tracking:
		source_npc.rotation.y = lerp_angle(source_npc.rotation.y, atan2(source_npc.direction.x, source_npc.direction.z),10*delta)
		var current_location = source_npc.global_position
		var desired_location = source_npc.navigation_agent.get_next_path_position()
		var new_velocity = (desired_location - current_location).normalized() * source_npc.SPEED
		source_npc.navigation_agent.set_velocity(new_velocity)
		var random_pos = NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().get_navigation_map(),Global.player.global_position)
		source_npc.navigation_agent.set_target_position(random_pos)

func _anim_finished(state: StringName):
	if state == "attack3":
		state_chart.send_event("back_away")

func check_distance_for_next_attack():
	attack_counter += 1
	var animation_tree_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
	var tree_root: AnimationNodeStateMachine = animation_tree.tree_root
	if tree_root.has_node("attack" + str(attack_counter)):
		if source_npc.global_position.distance_to(Global.player.global_position) < 3:
			animation_tree_playback.travel("attack" + str(attack_counter))
		else:
			animation_tree.set("parameters/conditions/combo_attack", false)
			animation_tree.set("parameters/conditions/attack", false)
			state_chart.send_event("back_away")
	else:
		animation_tree.set("parameters/conditions/combo_attack", false)
		animation_tree.set("parameters/conditions/attack", false)
		state_chart.send_event("back_away")

func set_attack_value(value: bool):
	animation_tree.set("parameters/conditions/attack", value)

func update_attack_tracking(value: bool):
	attack_tracking = value
	if !value:
		source_npc.SPEED = 0
	if value:
		source_npc.SPEED = 4
