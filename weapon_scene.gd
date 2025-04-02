class_name Weapon
extends Node3D

@export var player_lookat_ray: RayCast3D
@export var hit_particles_add: PackedScene
@export var hit_sound: Dictionary[String,AudioStream]

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_chart: StateChart = $StateChart


var can_attack: bool = true


func _ready() -> void:
	state_chart.set_expression_property("can_attack", true)


func _on_damage_component_body_entered(body: Node3D) -> void:
	if body.get_groups().is_empty():
		hit_particles_add = load("res://hitparticles.tscn")
		AudioManager.play_sound(hit_sound["rock"],player_lookat_ray.get_collision_point(),-20.0)
		var hit_particles = hit_particles_add.instantiate()
		get_tree().current_scene.add_child(hit_particles)
		hit_particles.global_position = player_lookat_ray.get_collision_point()
		hit_particles.emitting = true
		hit_particles.get_child(0).emitting = true
	
	if player_lookat_ray.is_colliding() && player_lookat_ray.get_collider() == body && !body.get_groups().is_empty():
		match body.get_groups()[0]:
			&"world":
				hit_particles_add = load("res://hitparticles.tscn")
				AudioManager.play_sound(hit_sound["world"],player_lookat_ray.get_collision_point(),-20.0)
			&"enemy":
				hit_particles_add = load("res://bloodparticles.tscn")
				AudioManager.play_sound(hit_sound["enemy"],player_lookat_ray.get_collision_point(),-20.0)
			&"rock":
				hit_particles_add = load("res://hitparticles.tscn")
				AudioManager.play_sound(hit_sound["rock"],player_lookat_ray.get_collision_point(),-20.0)
			&"tree":
				hit_particles_add = load("res://woodparticles.tscn")
				AudioManager.play_sound(hit_sound["tree"],player_lookat_ray.get_collision_point(),-20.0)
			_:
				hit_particles_add = load("res://hitparticles.tscn")
				AudioManager.play_sound(hit_sound["world"],player_lookat_ray.get_collision_point(),-20.0)
				
		var hit_particles = hit_particles_add.instantiate()
		get_tree().current_scene.add_child(hit_particles)
		hit_particles.global_position = player_lookat_ray.get_collision_point()
		hit_particles.emitting = true
		hit_particles.get_child(0).emitting = true


func _on_damage_component_area_entered(area: Area3D) -> void:
		if area.get_groups().is_empty(): 
			hit_particles_add = load("res://hitparticles.tscn")
			AudioManager.play_sound(hit_sound["rock"],player_lookat_ray.get_collision_point(),-20.0)
			var hit_particles = hit_particles_add.instantiate()
			get_tree().current_scene.add_child(hit_particles)
			hit_particles.global_position = player_lookat_ray.get_collision_point()
			hit_particles.emitting = true
			hit_particles.get_child(0).emitting = true
			
		if player_lookat_ray.is_colliding() && player_lookat_ray.get_collider() == area && !area.get_groups().is_empty():
			match area.get_groups()[0]:
				&"world":
					hit_particles_add = load("res://hitparticles.tscn")
					AudioManager.play_sound(hit_sound["world"],player_lookat_ray.get_collision_point(),-20.0)
				&"enemy":
					hit_particles_add = load("res://bloodparticles.tscn")
					AudioManager.play_sound(hit_sound["enemy"],player_lookat_ray.get_collision_point(),-20.0)
				&"rock":
					hit_particles_add = load("res://hitparticles.tscn")
					AudioManager.play_sound(hit_sound["world"],player_lookat_ray.get_collision_point(),-20.0)
				&"tree":
					hit_particles_add = load("res://woodparticles.tscn")
					AudioManager.play_sound(hit_sound["tree"],player_lookat_ray.get_collision_point(),-20.0)
				_:
					hit_particles_add = load("res://hitparticles.tscn")
					AudioManager.play_sound(hit_sound["world"],player_lookat_ray.get_collision_point(),-20.0)
				
			var hit_particles = hit_particles_add.instantiate()
			get_tree().current_scene.add_child(hit_particles)
			hit_particles.global_position = player_lookat_ray.get_collision_point()
			hit_particles.emitting = true
		
