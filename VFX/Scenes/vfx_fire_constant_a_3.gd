extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ray: RayCast3D = $RayCast3D
@onready var dynamicmarks: GPUParticles3D = $dynamicmarks

func activate():
	animation_player.play("Init")

func end():
	animation_player.play("End")

func _process(delta: float) -> void:
	if ray.is_colliding():
		dynamicmarks.global_position = ray.get_collision_point()
