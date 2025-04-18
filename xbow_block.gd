extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@export var state_chart: StateChart
@export var weapon: Node3D

func _on_block_state_entered() -> void:
	animation_player.play("raise_xbow",-1,.75)
	AudioManager.play_sound(load("res://Player/weapon/ALL/Shield/leather_inventory.wav"),weapon.global_position,-4.0)
	SignalBus.emit_signal("is_blocking",true)


func _on_block_state_exited() -> void:
	animation_player.play("raise_xbow",-1,-.75,true)
	AudioManager.play_sound(load("res://Player/weapon/ALL/Shield/leather_inventory.wav"),weapon.global_position,-4.0)


func _on_block_state_processing(delta: float) -> void:
	if Input.is_action_just_released("attack_secondary"):
		state_chart.send_event("block_released")
