extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var state_chart: StateChart = $"../../.."




func _on_held_left_state_entered() -> void:
	animation_player.play("hold_left")
	SignalBus.emit_signal("can_attack", false)
	SignalBus.emit_signal("primary_active",true)


func _on_held_left_state_exited() -> void:
	pass # Replace with function body.


func _on_held_left_state_processing(delta: float) -> void:
	if not (animation_player.is_playing() or Input.is_action_pressed("attack_primary")):
		state_chart.send_event("attack_left")
