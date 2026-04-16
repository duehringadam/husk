extends Node

@export var state_chart: StateChart
@export var animation_tree: AnimationTree
@export var right_hand: Marker3D

func _on_right_state_entered() -> void:
	animation_tree.set("parameters/conditions/hold_right", true)


func _on_right_state_exited() -> void:
	pass


func _on_right_state_input(event: InputEvent) -> void:
	if event.is_action_released("attack_primary"):
		animation_tree.set("parameters/conditions/hold_right", false)
		state_chart.send_event("swing")


func _on_right_state_physics_processing(delta: float) -> void:
	if not (Input.is_action_pressed("attack_primary")):
		animation_tree.set("parameters/conditions/hold_right", false)
		state_chart.send_event("swing")
	if !animation_tree["parameters/playback"].is_playing:
		animation_tree.set("parameters/conditions/hold_right", false)
		state_chart.send_event("swing")
