extends Node

@export var state_chart: StateChart
@export var bone_attach: BoneAttachment3D
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var hand: Node3D

func _on_shoot_state_entered() -> void:
	animation_tree["parameters/rangedBlendTree/Transition/transition_request"] = "shoot"

	var anim_length = animation_tree.get("parameters/rangedBlendTree/output/current_length")
	var anim_current_pos = animation_tree.get("parameters/rangedBlendTree/output/current_position")
	
	var time_left = anim_length
	await get_tree().create_timer(time_left).timeout
	state_chart.send_event("idle")


func _on_shoot_state_exited() -> void:
	pass # Replace with function body.


func _on_shoot_state_input(event: InputEvent) -> void:
	pass # Replace with function body.


func _on_shoot_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
