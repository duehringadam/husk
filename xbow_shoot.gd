extends Node

@export var weapon: Node3D
@export var state_chart: StateChart
@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"


func _on_shoot_state_entered() -> void:
	Global.player.camera.apply_shake()
	Global.player.viewport_camera.apply_shake()
	AudioManager.play_sound(weapon.swing_sound,weapon.global_position,-25.0)
	animation_player.play("shoot")
	await animation_player.animation_finished
	state_chart.send_event("reload")


func _on_shoot_state_exited() -> void:
	pass # Replace with function body.


func _on_shoot_state_processing(delta: float) -> void:
	pass # Replace with function body.
