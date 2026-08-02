extends Node

@export var weapon: Node3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree


func _on_lower_arm_state_entered() -> void:
	animation_tree.set("parameters/conditions/lower", true)


func _on_lower_arm_state_exited() -> void:
	animation_tree.set("parameters/conditions/lower", false)


func _on_lower_arm_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
