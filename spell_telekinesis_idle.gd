extends Node

@onready var state_chart: StateChart = $"../../.."
@onready var hold_particles: GPUParticles3D = %hold_particles
@onready var spell: Node3D = $"../../../.."
@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var spell_hold_sound: AudioStreamPlayer3D = $"../../../../spell_hold_sound"
@onready var spell_shapecast: ShapeCast3D = %spell_shapecast

func _on_idle_state_entered() -> void:
	animation_player.play("RESET")
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov",Global.camera_fov,.25)
	SignalBus.emit_signal("can_attack", true)
	SignalBus.emit_signal("secondary_active",false)
	state_chart.set_expression_property("can_attack", true)
	spell_hold_sound.playing = false
	hold_particles.emitting = false


func _on_idle_state_exited() -> void:
	SignalBus.emit_signal("secondary_active",true)
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov",Global.camera_fov+10,.25)


func _on_idle_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_pressed("attack_secondary") && spell.grabbed_object == null:
		AudioManager.play_sound(load("res://sfx/telekeroppomimipickup2.wav"),spell.global_position,-10)
		AudioManager.play_sound(load("res://sfx/fire-magic-5-378639.mp3"), spell.global_position, -10)
		animation_player.play("pull_object")
		if spell_shapecast.is_colliding():
			var colliders =  spell_shapecast.get_collision_count()
			var base_object := spell_shapecast.get_collider(0)
			for i in colliders:
				if spell_shapecast.get_collider(i).is_in_group("throwable"):
					var check_dist = spell_shapecast.get_collider(i).global_position.distance_to(Global.player.global_position)
					if check_dist < base_object.global_position.distance_to(Global.player.global_position):
						base_object = spell_shapecast.get_collider(i)
					spell.grabbed_object = base_object
					state_chart.send_event("pull")
					return
				else:
					spell.grabbed_object = null

		if spell.grabbed_object == null:
			await animation_player.animation_finished
			state_chart.send_event("missed")
		
