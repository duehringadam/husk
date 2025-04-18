extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var state_chart: StateChart = $"../../.."
@export var weapon: Node3D

func _on_raised_state_entered() -> void:
	SignalBus.emit_signal("is_blocking",true)
	SignalBus.emit_signal("secondary_active", true)
	animation_player.play("raise_shield")
	AudioManager.play_sound(load("res://Player/weapon/ALL/Shield/leather_inventory.wav"),weapon.global_position,-4.0)


func _on_raised_state_exited() -> void:
	animation_player.play("raise_shield",-1,-1,true)
	AudioManager.play_sound(load("res://Player/weapon/ALL/Shield/leather_inventory.wav"),weapon.global_position,-4.0)


func _on_raised_state_processing(delta: float) -> void:
	if Input.is_action_just_released("attack_secondary"):
		state_chart.send_event("secondary_released")
