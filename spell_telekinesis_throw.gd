extends Node

@onready var state_chart: StateChart = $"../../.."
@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var spell_telekinesis: Node3D = $"../../../.."
@onready var hold_particles: GPUParticles3D = %hold_particles


func _on_throw_state_entered() -> void:
	SignalBus.emit_signal("telekinesis")
	
	AudioManager.play_sound(load("res://sfx/fire-magic-6-378641.mp3"), spell_telekinesis.global_position, 0)
	AudioManager.play_sound(load("res://sfx/teleketeletThrowTHREE.wav"), spell_telekinesis.global_position, 10)
	
	hold_particles.emitting = false
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov",Global.camera_fov,.25)
	Global.player.camera.apply_shake()
	await animation_player.animation_finished
	state_chart.send_event("idle")


func _on_throw_state_exited() -> void:
	if is_instance_valid(spell_telekinesis.grabbed_object):
		spell_telekinesis.grabbed_object.throw_power /= spell_telekinesis.throw_power_multiplier
		spell_telekinesis.grabbed_object= null


func _on_throw_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
