extends Area3D
@onready var mesh: MeshInstance3D = $"../MeshInstance3D"
@onready var bolt: Node3D = $".."

func _physics_process(delta: float) -> void:
	if monitoring:
		for i in get_overlapping_bodies():
			if i.is_in_group("limb_sever"):
				mesh.reparent(i)
				mesh.position = Vector3.ZERO
				i.apply_central_impulse(bolt.transform.basis * Vector3(0,0,-bolt.speed/5.0 * i.mass))
				bolt.queue_free()
