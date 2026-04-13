class_name Weapon
extends Node3D

signal damage_dealt

@export var hit_particles_add: PackedScene
@export var swing_sound: AudioStreamPlayer3D
@export var block_sound: AudioStreamPlayer3D
@export var equip_sound: AudioStreamPlayer3D
@export var damage_component: DamageComponent
@export var blood_drip: GPUParticles3D
@export var bloodtimer: Timer
@export var weapon_mesh: MeshInstance3D

@export var trail: GPUTrail3D

var can_attack: bool = true
var secondary_active_bool: bool = false
var tween: Tween

func _ready() -> void:
	damage_component.source = Global.player
	equip_sound.play()


func _on_bloodtimer_timeout() -> void:
	blood_drip.emitting = false
	remove_blood()

func _on_damage_component_damage_dealt(types: Dictionary[DamageTypes.DAMAGE_TYPES, float], actual: float, stance_damage:float, target: hurtbox_component) -> void:
	Global.player.camera.apply_shake(0.04)
	if !target.can_bleed:
		return
		
	var weapon_mesh_shader = weapon_mesh.get_active_material(0)
	weapon_mesh_shader.next_pass["shader_parameter/progress"] = clampf(weapon_mesh_shader.next_pass["shader_parameter/progress"]+.05,0,.5)
	if weapon_mesh_shader.next_pass["shader_parameter/progress"] >= .2 && blood_drip != null:
		blood_drip.emitting = true
		bloodtimer.start()
	else:
		blood_drip.emitting = false

func remove_blood():
	blood_drip.emitting = false
	var weapon_mesh_shader = weapon_mesh.get_active_material(0)
	tween = get_tree().create_tween()
	tween.tween_property(weapon_mesh_shader.next_pass,"shader_parameter/progress",0,60)
