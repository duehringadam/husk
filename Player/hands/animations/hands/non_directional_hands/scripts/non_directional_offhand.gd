extends Node

@export var state_chart: StateChart
@export var bone_attach: BoneAttachment3D
@export var animation_tree: AnimationTree

@export var hand: Node3D


var playback: AnimationNodeStateMachinePlayback

func _on_offhand_activate_state_entered() -> void:
	playback = animation_tree.get("parameters/playback")
	animation_tree.set("parameters/conditions/offhand", true)
	animation_tree.set("parameters/offhandActivateBlendTree/Transition/transition_request", "activate")
	
func _on_offhand_activate_state_exited() -> void:
	animation_tree.set("parameters/offhandActivateBlendTree/Transition/transition_request", "deactivate")
	animation_tree.set("parameters/conditions/offhand", false)

func _on_offhand_activate_state_physics_processing(delta: float) -> void:
	pass

func _on_offhand_activate_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_primary"):
		animation_tree.set("parameters/conditions/offhand", false)
		state_chart.send_event("swing")
	if event.is_action_released("attack_secondary"):
		var anim_length = animation_tree.get("parameters/offhandActivateBlendTree/output/current_length")
		var anim_current_pos = animation_tree.get("parameters/offhandActivateBlendTree/output/current_position")
		
		var time_left = anim_length - anim_current_pos
		await get_tree().create_timer(time_left).timeout
		bone_attach.get_child(0).deactivate()
		animation_tree.set("parameters/offhandActivateBlendTree/Transition/transition_request", "deactivate")
		state_chart.send_event("idle")
