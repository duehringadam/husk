extends Node

@export var state_chart: StateChart
@export var animation_tree: AnimationTree

func _on_left_state_entered() -> void:
	GamePiecesEventBus.slow_player_requested(1)
	animation_tree.set("parameters/conditions/hold_left", true)


func _on_left_state_exited() -> void:
	animation_tree.set("parameters/conditions/hold_left", false)


func _on_left_state_processing(delta: float) -> void:
		if not (Input.is_action_pressed("attack_primary")):
			state_chart.send_event("swing")
