extends Node

@export var state_chart: StateChart
@export var animation_tree: AnimationTree

func _on_idle_state_entered() -> void:
	animation_tree.set("parameters/conditions/idle", true)
	animation_tree.set("parameters/conditions/shoot", false)
	animation_tree.set("parameters/conditions/aim", false)


func _on_idle_state_exited() -> void:
	pass # Replace with function body.


func _on_idle_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_idle_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_secondary"):
		state_chart.send_event("raise")
