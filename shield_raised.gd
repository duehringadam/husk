extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var state_chart: StateChart = $"../../.."
@export var weapon: Node3D
@onready var raise: AudioStreamPlayer3D = $"../../../../Cube/raise"

func _on_raised_state_entered() -> void:
	SignalBus.emit_signal("is_blocking",true)
	SignalBus.emit_signal("secondary_active", true)
	animation_player.play("raise_shield")
	raise.play()


func _on_raised_state_exited() -> void:
	pass


func _on_raised_state_processing(delta: float) -> void:
	if Input.is_action_just_released("attack_secondary"):
		raise.play()
		animation_player.play("raise_shield",-1,-1,true)
		await animation_player.animation_finished
		state_chart.send_event("secondary_released")
