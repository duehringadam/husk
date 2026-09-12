extends Node

@export var state_chart: StateChart
@export var bone_attach: BoneAttachment3D
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var hand: Node3D


func _on_offhand_activate_state_entered() -> void:
	animation_tree.set("parameters/conditions/block", true)
	bone_attach.get_child(0).activate()


func _on_offhand_activate_state_exited() -> void:
	animation_tree.set("parameters/conditions/block", false)

func _on_offhand_activate_state_physics_processing(delta: float) -> void:
	pass

func _on_offhand_activate_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_primary"):
		animation_tree.set("parameters/conditions/block", false)
		state_chart.send_event("swing")
	if event.is_action_released("attack_secondary"):
		bone_attach.get_child(0).deactivate()
		animation_tree.set("parameters/conditions/block", false)
		state_chart.send_event("idle")
