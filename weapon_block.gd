extends Node

@export var state_chart: StateChart
@export var weapon: Node3D
@export var animation_tree: AnimationTree

func _on_block_state_entered() -> void:
	animation_tree.set("parameters/conditions/block", true)


func _on_block_state_exited() -> void:
	pass


func _on_block_state_processing(delta: float) -> void:
	if not Input.is_action_pressed("secondary_action"):
		animation_tree.set("parameters/conditions/block", false)
		state_chart.send_event("idle")
