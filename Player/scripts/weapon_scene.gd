class_name Weapon
extends Node3D

signal damage_dealt

@export var hit_particles_add: GPUParticles3D
@export var damage_sound: AudioStreamPlayer3D
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

func activate(value: bool):
	trail.visible = value
	
	if value:
		swing_sound.pitch_scale = randf_range(0.9,1.1)
		swing_sound.play()

func _on_bloodtimer_timeout() -> void:
	blood_drip.emitting = false
	remove_blood()

func remove_blood():
	blood_drip.emitting = false
