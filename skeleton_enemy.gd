extends CharacterBody3D
@onready var animation_player: AnimationPlayer = $skeleton_fixed/AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $skeleton_fixed/NavigationAgent3D
@onready var bone_simulator: PhysicalBoneSimulator3D = $skeleton_fixed/metarig/Skeleton3D/PhysicalBoneSimulator3D
@onready var beehave_tree: BeehaveTree = $BeehaveTree
@onready var phys_timer: Timer = $phys_timer

@export var SPEED: float

func _ready() -> void:
	animation_player.play("metarig|idle",-1,.5)

func _physics_process(delta: float) -> void:
	var direction = Vector3()
	
	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * SPEED,1)
	
	move_and_slide()


func _on_health_component_died() -> void:
	bone_simulator.physical_bones_start_simulation()
	beehave_tree.enabled = false
	phys_timer.start()


func _on_timer_timeout() -> void:
	bone_simulator.physical_bones_stop_simulation()
