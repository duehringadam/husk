extends Node

@export var left_hand: Marker3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree

func _on_lower_state_entered() -> void:
	animation_tree.set("parameters/conditions/lower", true)


func _on_lower_state_exited() -> void:
	animation_tree.set("parameters/conditions/lower", false)


func _on_lower_state_input(event: InputEvent) -> void:
	pass # Replace with function body.


func _on_lower_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
