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

@export var blood_decals: Array[Decal]

var can_attack: bool = true
var secondary_active_bool: bool = false
var tween: Tween

func _ready() -> void:
	damage_component.source = Global.player
	equip_sound.play()

func activate(value: bool):
	trail.visible = value

func _on_bloodtimer_timeout() -> void:
	blood_drip.emitting = false
	remove_blood()

func _on_damage_component_damage_dealt(types: Dictionary[DamageTypes.DAMAGE_TYPES, float], actual: float, stance_damage:float, target: hurtbox_component, slow_amount: float) -> void:
	if !target.can_bleed:
		return
		
	if blood_decals.size() <= 0: return
	
	var random_decal_idx = randi_range(0, blood_decals.size()-1)
	
	var decal: Decal = blood_decals[random_decal_idx]
	
	decal.modulate.a += 0.05
	
func remove_blood():
	blood_drip.emitting = false
