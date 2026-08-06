extends Node

@export var left_hand: Marker3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree

func _on_cant_use_state_entered() -> void:
	animation_tree.set("parameters/conditions/activate", false)
	animation_tree.set("parameters/conditions/cant_use", true)
	await animation_tree["parameters/playback"].state_finished
	animation_tree.set("parameters/conditions/cant_use", false)
	state_chart.send_event("idle")


func _on_cant_use_state_exited() -> void:
	animation_tree.set("parameters/conditions/cant_use", false)


func _on_cant_use_state_input(event: InputEvent) -> void:
	pass # Replace with function body.


func _on_cant_use_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
