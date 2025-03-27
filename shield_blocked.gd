extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var state_chart: StateChart = $"../../.."
@export var shield: Node3D

func _on_blocked_state_entered() -> void:
	
	await animation_player.animation_finished
	if not Input.is_action_pressed("attack_secondary"):
		state_chart.send_event("block_released")
	else:
		state_chart.send_event("block_held")

func _on_blocked_state_exited() -> void:
	pass

func _on_blocked_state_processing(delta: float) -> void:
	pass # Replace with function body.
