extends Node

@export var animation_tree: AnimationTree
@onready var firesfx: AudioStreamPlayer3D = $"../../../../TargetIKLeft/GPUParticles3D/firesfx"
@onready var state_chart: StateChart = $"../../.."

func _on_spray_state_entered() -> void:
	animation_tree.set("parameters/conditions/attack", true)
	animation_tree.set("parameters/conditions/idle", false)
	


func _on_spray_state_exited() -> void:
	pass # Replace with function body.


func _on_spray_state_input(event: InputEvent) -> void:
	if event.is_action_released("attack_secondary"):
		SignalBus.emit_signal("raidal_blur", false)
		firesfx.stop()
		GamePiecesEventBus.slow_player_requested(-2)
		animation_tree.set("parameters/conditions/attack", false)
		state_chart.send_event("idle")
