extends Node3D


@export var player_lookat_ray: RayCast3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_chart: StateChart = $StateChart

var hit_particles_add = preload("res://hitparticles.tscn")

func _on_damage_component_body_entered(body: Node3D) -> void:
	if player_lookat_ray.is_colliding() && player_lookat_ray.get_collider() == body:
		var hit_particles = hit_particles_add.instantiate()
		get_tree().current_scene.add_child(hit_particles)
		hit_particles.global_position = player_lookat_ray.get_collision_point()
		hit_particles.emitting = true
		hit_particles.get_child(0).emitting=true
		AudioManager.play_sound(load("res://sfx/metal-hit-91-200421.mp3"),player_lookat_ray.get_collision_point(),-20.0)
