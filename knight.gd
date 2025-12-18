class_name NPC
extends Node3D

@export var hurtbox: hurtbox_component
@export var sheet_id: String

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent
@onready var bone_simulator: PhysicalBoneSimulator3D = %PhysicalBoneSimulator3D
@onready var physicstimeout: Timer = $physicstimeout
@export var can_bleed: bool = true
@onready var hit_particles: GPUParticles3D = $bloodparticles
@onready var root_joint: PhysicalBone3D = $"Skeleton3D/PhysicalBoneSimulator3D/Physical Bone mixamorig_Hips_24"
@onready var body: MeshInstance3D = $Skeleton3D/Object_9
@onready var look_at_modifier_3d: LookAtModifier3D = $Skeleton3D/LookAtModifier3D
@onready var interaction_collision: StaticBody3D = $interaction_collision


var _interaction_controller: InteractionController = null
var is_talking:= false

func _ready():
	animation_player.play("Idle")


func _on_health_component_died() -> void:
	hurtbox.monitorable = false
	hurtbox.monitoring = false
	animation_player.stop()
	bone_simulator.physical_bones_start_simulation()

func fall(push_dir: Vector3 = Vector3.ZERO):
	interaction_collision.queue_free()
	animation_player.stop()
	bone_simulator.physical_bones_start_simulation()
	root_joint.apply_central_impulse(push_dir*25)
	physicstimeout.start()

func _on_hurtbox_component_damage_taken(actual: float, source: DamageComponent, hit_dir: Vector3) -> void:
	hit_particles.global_position = hurtbox.global_position
	hit_particles.take_damage()


func _on_physicstimeout_timeout() -> void:
	hurtbox.monitoring = false


func _on_talk_on_complete(controller: InteractionController) -> void:
	is_talking = true
	look_at_modifier_3d.target_node = Global.player.head.get_path()
	SignalBus.emit_signal("npc_interacted", sheet_id)


func _on_stance_component_stance_broken() -> void:
	fall()
