extends Node

@export var state_chart: StateChart
@export var animation_tree: AnimationTree


func _on_right_state_entered() -> void:
	animation_tree.set("parameters/conditions/hold_right", true)


func _on_right_state_exited() -> void:
	
	animation_tree.set("parameters/conditions/hold_right", false)


func _on_right_state_processing(delta: float) -> void:
		if not (Input.is_action_pressed("attack_primary") and animation_tree.animation_finished):
			state_chart.send_event("swing")
