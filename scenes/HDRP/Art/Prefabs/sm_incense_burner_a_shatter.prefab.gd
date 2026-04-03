extends Node3D
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

func break_mesh(velocity, material):
	gpu_particles_3d.emitting = true
	for i in get_children():
		if i is RigidBody3D:
			i.freeze = false
			i.apply_central_impulse(velocity)
			for c in i.get_children():
				if c is MeshInstance3D:
					c.set_surface_override_material(0,material)
					var _material = c.get_surface_override_material(0)
		
	get_tree().create_timer(25).timeout.connect(func(): self.queue_free())
	
