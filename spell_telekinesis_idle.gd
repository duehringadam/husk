extends Node

@export var state_chart: StateChart
@export var spell: Node3D

@onready var hold_particles: GPUParticles3D = %hold_particles
@onready var spell_hold_sound: AudioStreamPlayer3D = $"../../../../spell_hold_sound"
@onready var spell_shapecast: ShapeCast3D = %spell_shapecast
@onready var spell_cast_sound: AudioStreamPlayer3D = $"../../../../spell_cast_sound"

func _on_idle_state_entered() -> void:
	spell.grabbed_object = null
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov",Global.camera_fov,.25)
	SignalBus.emit_signal("can_attack", true)
	SignalBus.emit_signal("secondary_active",false)
	state_chart.set_expression_property("can_attack", true)
	spell_hold_sound.playing = true
	hold_particles.emitting = false


func _on_idle_state_exited() -> void:
	SignalBus.emit_signal("secondary_active",true)
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov",Global.camera_fov+10,.25)


func _on_idle_state_physics_processing(delta: float) -> void:
	if spell.is_active && spell.grabbed_object == null:
		#AudioManager.play_sound(load("res://sfx/telekeroppomimipickup2.wav"),spell.global_position,-20)
		if spell_shapecast.is_colliding():
			var colliders =  spell_shapecast.get_collision_count()
			var base_object := spell_shapecast.get_collider(0)
			for i in colliders:
				if spell_shapecast.get_collider(i).is_in_group("throwable") or spell_shapecast.get_collider(i) is Pickable:
					var check_dist = spell_shapecast.get_collider(i).global_position.distance_to(Global.player.global_position)
					if check_dist < base_object.global_position.distance_to(Global.player.global_position):
						base_object = spell_shapecast.get_collider(i)
					if base_object.is_in_group("throwable"):
						spell.grabbed_object = base_object
						state_chart.send_event("pull")
						AudioManager.play_sound(load("res://sfx/fire-magic-5-378639.mp3"), spell.global_position, -20)
		
