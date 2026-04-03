extends Node

@export var state_chart: StateChart
@export var animation_tree: AnimationTree

func _on_raised_state_entered() -> void:
	GamePiecesEventBus.slow_player_requested(2)
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/aim", true)


func _on_raised_state_exited() -> void:
	GamePiecesEventBus.slow_player_requested(-2)


func _on_raised_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_released("attack_secondary"):
		animation_tree.set("parameters/conditions/idle", false)
		state_chart.send_event("idle")
	if Input.is_action_pressed("attack_primary") and not Input.is_action_just_released("attack_secondary"):
		state_chart.send_event("shoot")

func _on_raised_state_input(event: InputEvent) -> void:
	pass
