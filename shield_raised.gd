extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var state_chart: StateChart = $"../../.."


func _on_raised_state_entered() -> void:
	SignalBus.emit_signal("secondary_active", true)
	animation_player.play("raise_shield")


func _on_raised_state_exited() -> void:
	animation_player.play("raise_shield",-1,-1,true)


func _on_raised_state_processing(delta: float) -> void:
	if Input.is_action_just_released("attack_secondary"):
		state_chart.send_event("secondary_released")
