extends CharacterBody3D
@onready var animation_player: AnimationPlayer = $skeleton_fixed/AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $skeleton_fixed/NavigationAgent3D

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
	queue_free()
