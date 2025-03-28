extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var state_chart: StateChart = $"../../.."


func _on_held_left_state_entered() -> void:
	animation_player.play("hold_left")


func _on_held_left_state_exited() -> void:
	pass # Replace with function body.


func _on_held_left_state_processing(delta: float) -> void:
	if animation_player.is_playing():
		if Input.is_action_just_released("attack_primary"):
			await animation_player.animation_finished
			state_chart.send_event("attack_left")
	else:
		if Input.is_action_just_released("attack_primary"):
			state_chart.send_event("attack_left")
