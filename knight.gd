extends Node3D

@export var hurtbox: hurtbox_component
@export var hip_bone: PhysicalBone3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent
@onready var bone_simulator: PhysicalBoneSimulator3D = $Skeleton3D/PhysicalBoneSimulator3D
@onready var physicstimeout: Timer = $physicstimeout
@onready var dialogue_interact_component: DialogueInteractComponent = $DialogueInteractComponent

var timer: float = 0.0

func _ready():
	animation_player.play("Idle")

func _process(delta: float) -> void:
	timer += delta
	if timer >= 0.15:
		animation_player.advance(timer)
		timer = 0

func _on_health_component_died() -> void:
	hurtbox.monitorable = false
	hurtbox.monitoring = false
	dialogue_interact_component.monitoring = false
	dialogue_interact_component.monitorable = false
	animation_player.stop()
	bone_simulator.physical_bones_start_simulation()
	physicstimeout.start()


func _on_hurtbox_component_damage_taken(amount: float, actual: float, source: DamageComponent) -> void:
	var hit_particles = hurtbox.damage_particles.instantiate()
	get_tree().current_scene.add_child(hit_particles)
	hit_particles.global_position = hurtbox.global_position
	hit_particles.emitting = true


func _on_physicstimeout_timeout() -> void:
	bone_simulator.physical_bones_stop_simulation()
	hurtbox.monitoring = false
