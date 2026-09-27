class_name WaterAreaComponent
extends Area3D

@export var slow_amount: int = 2
@export var water_splash_particle_amount: int = 10
@export var water_surface_particle_amount: int = 10

var available_splash_particles: Array[GPUParticles3D]
var available_surface_particles: Array[GPUParticles3D]

var water_splash = preload("res://scenes/VFX/water_splash.tscn")
var water_surface = preload("res://scenes/VFX/water_surface.tscn")

var movement_timer: float = 0

#func _ready() -> void:
	#for i in range(water_surface_particle_amount):
		#var surface_particle: GPUParticles3D = water_surface.instantiate()
		#surface_particle.connect("finished", return_surface_object.bind(surface_particle))
		#add_child(surface_particle)
		#return_surface_object(surface_particle)
	#
	#for i in range(water_splash_particle_amount):
		#var splash_particle: GPUParticles3D = water_splash.instantiate()
		#splash_particle.connect("finished", return_splash_object.bind(splash_particle))
		#add_child(splash_particle)
		#return_splash_object(splash_particle)
	#
	#if !self.has_meta("ground_type"):
		#self.set_meta("ground_type", "water")
		#
	#if !body_entered.is_connected(_on_body_entered):
		#body_entered.connect(_on_body_entered)
	#if !body_exited.is_connected(_on_body_entered):
		#body_exited.connect(_on_body_exited)

#func _physics_process(delta: float) -> void:
	#for i in get_overlapping_bodies():
		#movement_timer += delta
		#if i is RigidBody3D and i.linear_velocity.length() > 0:
			#if movement_timer > .75:
				#movement_timer = 0
				#var water_surface_add = get_surface_object()
				#if water_surface_add != null:
					#water_surface_add.global_position = i.global_position
		#if i is Player and i.velocity.length() > 0:
			#if movement_timer > .75:
				#movement_timer = 0
				#var water_surface_add = get_surface_object()
				#if water_surface_add != null:
					#water_surface_add.global_position = i.global_position

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.slow_speed = slow_amount


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		body.slow_speed = 0

#func get_splash_object() -> GPUParticles3D:
	#var object: Node3D
	#if !available_splash_particles.is_empty():
		#object = available_splash_particles.pop_back()
		#activate_object(object)
	#return object
#
#func get_surface_object() -> GPUParticles3D:
	#var object: Node3D
	#if !available_surface_particles.is_empty():
		#object = available_surface_particles.pop_back()
		#activate_object(object)
	#return object
#
#func return_splash_object(object: GPUParticles3D):
	#deactivate_object(object)
	#available_splash_particles.append(object)
#
#func return_surface_object(object: GPUParticles3D):
	#deactivate_object(object)
	#available_surface_particles.append(object)
#
#func activate_object(object: GPUParticles3D):
	#object.activate()
#
#func deactivate_object(object: GPUParticles3D):
	#object.deactivate()
