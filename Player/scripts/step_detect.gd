extends Node3D


@export var step_detect: RayCast3D
@export var separation_ray: CollisionShape3D
@export var player: Player

@onready var front_raycast: RayCast3D = $frontRaycast
@onready var front_wall_raycast: RayCast3D = $frontWallRaycast

func _physics_process(delta: float) -> void:
	rotation.y = atan2(-player.input_dir.x, -player.input_dir.z)
	if player.is_on_floor() && player.is_on_wall() && front_wall_raycast.is_colliding():
		if step_detect.is_colliding() && !front_raycast.is_colliding(): 
			var step_height = step_detect.get_collision_point().y - player.global_position.y
			player.global_position.y = lerpf(player.global_position.y, player.global_position.y+ step_height + 0.05, 40*delta)
