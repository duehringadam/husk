class_name Weapon
extends Node3D

@export var weapon_initial_position: Vector3
@export var two_handed: bool = false
@export_range(0.0,1.0) var block_amount: float
@export var hit_particles_add: PackedScene
@export var swing_sound: AudioStream
@export var hit_sound: AudioStream
@export var damage_component: DamageComponent
@export var blood_drip: GPUParticles3D
@export var bloodtimer: Timer
@export var weapon_mesh: MeshInstance3D
@export var state_chart: StateChart
@onready var animation_tree: AnimationTree = $AnimationTree

var can_attack: bool = true
var secondary_active_bool: bool = false
var tween: Tween

func _ready() -> void:
	self.position = weapon_initial_position
	SignalBus.connect("npc_interacted", _on_npc_interacted)
	SignalBus.connect("dialogue_ended", _on_dialogue_ended)

func _on_npc_interacted(sheet_id):
	can_attack = false

func _on_dialogue_ended():
	can_attack = true

func _on_bloodtimer_timeout() -> void:
	blood_drip.emitting = false
	remove_blood()

func _on_damage_component_damage_dealt(types: Dictionary[DamageTypes.DAMAGE_TYPES, float], actual: float, stance_damage:float, target: hurtbox_component) -> void:
	Global.player.camera.apply_shake(0.04)
	if !target.can_bleed:
		return
		
	var weapon_mesh_shader = weapon_mesh.get_active_material(0)
	weapon_mesh_shader.next_pass["shader_parameter/progress"] = clampf(weapon_mesh_shader.next_pass["shader_parameter/progress"]+.005,0,.5)
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

func block():
	animation_tree.set("parameters/conditions/block_hit", true)
	await get_tree().create_timer(.5).timeout
	animation_tree.set("parameters/conditions/block_hit", false)
