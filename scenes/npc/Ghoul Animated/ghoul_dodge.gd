extends Node

@export var source_npc: CharacterBody3D
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

func _on_dodge_state_entered() -> void:
	source_npc.SPEED = 0
	animation_tree.set("parameters/conditions/walk", false)
	var rand = randf()
	if rand > 0.5:
		animation_tree.set("parameters/conditions/dodgeLeft", true)
	else:
		animation_tree.set("parameters/conditions/dodgeRight", true)
	await animation_tree.animation_finished
	state_chart.send_event("move")

func _on_dodge_state_exited() -> void:
	animation_tree.set("parameters/conditions/dodgeRight", false)
	animation_tree.set("parameters/conditions/dodgeLeft", false)


func _on_dodge_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
