class_name NPC
extends Node3D

@export var hurtbox: hurtbox_component

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent
@onready var bone_simulator: PhysicalBoneSimulator3D = $Skeleton3D/PhysicalBoneSimulator3D
@onready var physicstimeout: Timer = $physicstimeout
@onready var dialogue_interact_component: DialogueInteractComponent = $DialogueInteractComponent
@export var can_bleed: bool = true
@onready var hit_particles: GPUParticles3D = $bloodparticles
@onready var root_joint: PhysicalBone3D = $"Skeleton3D/PhysicalBoneSimulator3D/Physical Bone mixamorig_Hips_24"

var timer: float = 0.0

func _ready():
	animation_player.play("Idle")

func _process(delta: float) -> void:
	timer += delta
	if timer >= 0.15:
		animation_player.advance(timer)
		timer -= 0.15
	
		
func _on_health_component_died() -> void:
	hurtbox.monitorable = false
	hurtbox.monitoring = false
	dialogue_interact_component.monitoring = false
	dialogue_interact_component.monitorable = false
	fall(Vector3.FORWARD)

func fall(push_dir: Vector3):
	animation_player.stop()
	bone_simulator.physical_bones_start_simulation()
	root_joint.apply_central_impulse(push_dir*25)
	physicstimeout.start()

func _on_hurtbox_component_damage_taken(actual: float, source: DamageComponent, hit_dir: Vector3) -> void:
	hit_particles.global_position = hurtbox.global_position
	hit_particles.take_damage()


func _on_physicstimeout_timeout() -> void:
	hurtbox.monitoring = false
