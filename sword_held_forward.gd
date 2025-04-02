extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var state_chart: StateChart = $"../../.."

func _on_held_forward_state_entered() -> void:
	animation_player.play("hold_forward")


func _on_held_forward_state_exited() -> void:
	pass # Replace with function body.


func _on_held_forward_state_processing(delta: float) -> void:
	if not (animation_player.is_playing() or Input.is_action_pressed("attack_primary")):
		state_chart.send_event("attack_forward")
