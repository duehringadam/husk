extends Node

@export var weapon: Node3D
@export var state_chart: StateChart
@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"


func _on_reload_state_entered() -> void:
	AudioManager.play_sound(load("res://Player/weapon/ALL/Crossbow/crossbow-firing-95020.mp3"),weapon.global_position,0)
	animation_player.play("reload")
	await animation_player.animation_finished
	state_chart.send_event("idle")


func _on_reload_state_exited() -> void:
	pass # Replace with function body.


func _on_reload_state_processing(delta: float) -> void:
	pass # Replace with function body.
