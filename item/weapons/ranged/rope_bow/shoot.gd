extends Node

@export var state_chart: StateChart
@export var animation_tree: AnimationTree


func _on_shoot_state_entered() -> void:
	animation_tree.set("parameters/conditions/shoot", true)
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/aim", false)
	await animation_tree.animation_finished
	state_chart.send_event("idle")


func _on_shoot_state_exited() -> void:
	pass # Replace with function body.


func _on_shoot_state_input(event: InputEvent) -> void:
	pass # Replace with function body.


func _on_shoot_state_physics_processing(delta: float) -> void:
	pass
