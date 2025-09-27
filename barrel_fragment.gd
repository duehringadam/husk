extends Node3D



func break_mesh(velocity, material):
	for i in get_children():
		i.freeze = false
		i.apply_central_impulse(velocity)
		for c in i.get_children():
			if c is MeshInstance3D:
				c.set_surface_override_material(0,material)

	get_tree().create_timer(25).timeout.connect(func(): self.queue_free())
