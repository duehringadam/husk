extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var state_chart: StateChart = $"../../.."
@export var damage_component: DamageComponent
@export var weapon: Node3D

func _on_forward_state_entered() -> void:
	damage_component.monitorable = true
	damage_component.monitoring = true
	animation_player.play("swing_forward")
	AudioManager.play_sound(weapon.swing_sound,weapon.global_position,-0)
	await animation_player.animation_finished
	state_chart.send_event("idle")



func _on_forward_state_exited() -> void:
	damage_component.monitorable = false
	damage_component.monitoring = false


func _on_forward_state_processing(delta: float) -> void:
	pass # Replace with function body.
