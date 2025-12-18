extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var state_chart: StateChart = $"../../.."

func _on_missed_state_entered() -> void:
	animation_player.play("pull_object",-1,-1,true)
	await animation_player.animation_finished
	state_chart.send_event("idle")


func _on_missed_state_exited() -> void:
	pass # Replace with function body.


func _on_missed_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
