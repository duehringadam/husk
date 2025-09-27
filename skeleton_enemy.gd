extends CharacterBody3D


@onready var animation_player: AnimationPlayer = $skeleton_fixed/AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $skeleton_fixed/NavigationAgent3D
@onready var bone_simulator: PhysicalBoneSimulator3D = $skeleton_fixed/metarig/Skeleton3D/PhysicalBoneSimulator3D
@onready var phys_timer: Timer = $phys_timer

@export var SPEED: float
@export var damage_particles: PackedScene
@export var can_bleed: bool = true
var timer: float = 0.0
var hit_dir: Vector3

func _ready() -> void:
	animation_player.play("metarig|idle",-1,1)
	
func _process(delta: float) -> void:
	timer += delta
	if timer >= 0.05:
		animation_player.advance(timer)
		timer = 0
	

func _physics_process(delta: float) -> void:
	var direction = Vector3()
	
	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * SPEED,1)
	
	move_and_slide()


func _on_health_component_died() -> void:
	if hit_dir.x < 0:
		animation_player.play("death_left")
		
	if hit_dir.x > 0:
		animation_player.play("death_right")
		


func _on_timer_timeout() -> void:
	bone_simulator.physical_bones_stop_simulation()


func _on_hurtbox_component_damage_taken(amount: float, actual: float, source: DamageComponent, _hit_dir: Vector3) -> void:
	hit_dir = _hit_dir
	var hit_particles = damage_particles.instantiate()
	get_tree().current_scene.add_child(hit_particles)
	hit_particles.global_position = source.global_position
	hit_particles.emitting = true
	if _hit_dir.x < 0:
		animation_player.play("hit_right",-1,1.25)
	if _hit_dir.x > 0:
		animation_player.play("metarig|hit reaction",-1,1.25)
