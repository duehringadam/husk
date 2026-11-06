extends Node

@export var state_chart: StateChart
@export var bone_attach: BoneAttachment3D
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var hand: Node3D

func _on_aim_ranged_state_entered() -> void:
	animation_tree.set("parameters/conditions/aim", true)
	animation_tree["parameters/rangedBlendTree/Transition/transition_request"] = "aim"

func _on_aim_ranged_state_exited() -> void:
	animation_tree.set("parameters/conditions/aim", false)


func _on_aim_ranged_state_input(event: InputEvent) -> void:
	if event.is_action_released("attack_secondary"):
		var anim_length = animation_tree.get("parameters/rangedBlendTree/output/current_length")
		var anim_current_pos = animation_tree.get("parameters/rangedBlendTree/output/current_position")
		
		var time_left = anim_length - anim_current_pos
		await get_tree().create_timer(time_left).timeout
		animation_tree.set("parameters/conditions/idle", true)
		bone_attach.get_child(0).deactivate()
		state_chart.send_event("idle")
	
	if event.is_action_pressed("attack_primary"):
		var anim_length = animation_tree.get("parameters/rangedBlendTree/output/current_length")
		var anim_current_pos = animation_tree.get("parameters/rangedBlendTree/output/current_position")
		
		var time_left = anim_length - anim_current_pos
		await get_tree().create_timer(time_left).timeout
		state_chart.send_event("shoot")


func _on_aim_ranged_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
