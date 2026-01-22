extends Node

@export var state_chart: StateChart
@export var animation_tree: AnimationTree

var camera
var viewport_camera

func _on_forward_state_entered() -> void:
	GamePiecesEventBus.slow_player_requested(1)
	animation_tree.set("parameters/conditions/hold_forward", true)


func _on_forward_state_exited() -> void:
	
	animation_tree.set("parameters/conditions/hold_forward", false)


func _on_forward_state_processing(delta: float) -> void:
		if not (Input.is_action_pressed("attack_primary") and animation_tree.animation_finished):
			state_chart.send_event("swing")
