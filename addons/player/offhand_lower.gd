extends Node

@export var left_hand: Marker3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree

func _on_lower_state_entered() -> void:
	SignalBus.emit_signal("secondary_active", false)
	animation_tree.set("parameters/conditions/lower", true)
	animation_tree.set("parameters/conditions/idle", false)


func _on_lower_state_exited() -> void:
	animation_tree.set("parameters/conditions/lower", false)


func _on_lower_state_input(event: InputEvent) -> void:
	pass # Replace with function body.


func _on_lower_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
