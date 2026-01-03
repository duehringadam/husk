extends CharacterBody3D

@export var SPEED: float = 1
@export var arms_group: Array[StringName]
@onready var physical_bone_simulator: PhysicalBoneSimulator3D = %PhysicalBoneSimulator3D
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var beehave_tree: BeehaveTree = $BeehaveTree
@onready var hurtbox: hurtbox_component = %hurtbox_component
@onready var ghoul_parent: Node3D = %Ghoul
@onready var animation_player: AnimationPlayer = $Ghoul/AnimationPlayer

var aggro_activate := true
var timer: float = 0.0

func _ready() -> void:
	animation_tree.active = true

func _physics_process(delta: float) -> void:
	var direction = Vector3()
	
	direction = navigation_agent.get_next_path_position() - global_transform.origin
	direction = direction.normalized()
	self.rotation.y = lerp_angle(self.rotation.y, atan2(direction.x, direction.z),10*delta)
	velocity = velocity.lerp(direction * SPEED,1)
	
	_push_rigid_bodies()
	move_and_slide()

func _push_rigid_bodies():
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

func limp_arm():
	physical_bone_simulator.physical_bones_start_simulation(arms_group)

func _on_hurtbox_component_damage_taken(actual: float, source: DamageComponent, hit_dir: Vector3) -> void:
	animation_tree.set("parameters/conditions/flinch", true)
	get_tree().create_timer(.1).timeout.connect(func(): animation_tree.set("parameters/conditions/flinch", false))

func fall():
	physical_bone_simulator.physical_bones_start_simulation()
	hurtbox.monitorable = false
	hurtbox.monitoring = false
	beehave_tree.enabled = false
	SPEED = 0
	collision_layer = 0

func _on_health_component_died() -> void:
	var time_rand = randf_range(1,1.25)
	get_tree().create_timer(time_rand).timeout.connect(func(): physical_bone_simulator.physical_bones_start_simulation())
	collision_layer = 128
	hurtbox.monitorable = false
	hurtbox.monitoring = false
	animation_tree.set("parameters/conditions/dead", true)
	SPEED = 0
	beehave_tree.enabled = false
	#ghoul_parent.reparent(get_tree().current_scene)
	#self.queue_free()


func _on_stance_component_stance_broken() -> void:
	fall()
	beehave_tree.enabled = false
