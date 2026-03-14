extends Node

@export var animation_tree: AnimationTree
@onready var firesfx: AudioStreamPlayer3D = $"../../../../TargetIKLeft/GPUParticles3D/firesfx"
@onready var state_chart: StateChart = $"../../.."

func _on_idle_state_entered() -> void:
	animation_tree.set("parameters/conditions/idle", true)
	animation_tree.set("parameters/conditions/attack", false)


func _on_idle_state_exited() -> void:
	pass # Replace with function body.


func _on_idle_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_secondary"):
		SignalBus.emit_signal("raidal_blur", true)
		GamePiecesEventBus.slow_player_requested(2)
		firesfx.play()
		AudioManager.play_sound(load("res://sfx/fire-magic-5-378639.mp3"), firesfx.global_position, -15)
		state_chart.send_event("spray")
