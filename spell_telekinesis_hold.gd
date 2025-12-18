extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var spell_telekinesis: Node3D = $"../../../.."
@onready var state_chart: StateChart = $"../../.."
@onready var hold_particles: GPUParticles3D = %hold_particles

@onready var spell_hold_sound: AudioStreamPlayer3D = $"../../../../spell_hold_sound"

func _on_holding_state_entered() -> void:
	
	Global.player.camera.apply_shake()
	spell_hold_sound.playing = true
	hold_particles.emitting = true

func _on_holding_state_exited() -> void:
	spell_hold_sound.playing = false


func _on_holding_state_physics_processing(delta: float) -> void:
	if spell_telekinesis.grabbed_object != null:
		spell_telekinesis.grabbed_object._while_grabbed(Global.player._interaction_controller)
		if Input.is_action_just_pressed("attack_secondary") && spell_telekinesis.grabbed_object != null:
			animation_player.play("throw_object")
			state_chart.send_event("throw")
		if Input.is_action_pressed("attack_primary") && spell_telekinesis.grabbed_object != null:
			pass
	if !is_instance_valid(spell_telekinesis.grabbed_object):
		state_chart.send_event("missed")
