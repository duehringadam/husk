class_name npc
extends CharacterBody3D

@export_category("Variables")
@export var npc_name: String
@export var SPEED: float = 1
@export_range(0.0,1.0) var aggro := 0.0
@export var target: Node3D: set = _update_target

@export_category("Components")
@export var physical_bone_simulator: PhysicalBoneSimulator3D
@export var animation_tree: AnimationTree
@export var navigation_agent: NavigationAgent3D
@export var hurtboxes: Array[hurtbox_component]
@export var health_component: HealthComponent

@export_category("Behavior")
@export var state_chart: StateChart

@export var mesh: MeshInstance3D

var left_arm := true
var right_arm := true
var leg_attached := true : set = leg_lost
var head_attached := true : set = head_lost

var direction = Vector3()
var is_leader: bool = false

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	direction = navigation_agent.get_next_path_position() - global_transform.origin
	direction = direction.normalized()
	velocity = velocity.lerp(direction * SPEED, delta * 10)
	
	_push_rigid_bodies()
	move_and_slide()


func _push_rigid_bodies()-> void:
	if get_slide_collision_count() <= 0: return
	for i in get_slide_collision_count():
			var c := get_slide_collision(i)
			if c.get_collider() is RigidBody3D:
				var push_dir = -c.get_normal()
				var velocity_diff = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
				velocity_diff = max(0.0, velocity_diff)
				var approx_mass = 80.0
				var mass_ratio = min(1., approx_mass/c.get_collider().mass)
				var push_force = mass_ratio *  5
				c.get_collider().apply_impulse(push_dir * velocity_diff * push_force, c.get_position() - c.get_collider().global_position)
		
func leg_lost(value: bool)-> void:
	if !value:
		fall()
		
func head_lost(value: bool)-> void:
	if !value:
		_on_health_component_died()
	
func fall()-> void:
	pass

func _on_health_component_died() -> void:
	pass

func _on_stance_component_stance_broken() -> void:
	pass

func _update_target(value: Node3D):
	pass
