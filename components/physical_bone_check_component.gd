class_name PhysicalBoneCheckComponent
extends Area3D

@onready var bolt: PhysicsProjectile = $".."
@onready var pin: PinJoint3D = $"../PinJoint3D"

var pinned_bone: PhysicalBone3D

func _physics_process(delta: float) -> void:
	if !monitoring: return
	for i in get_overlapping_bodies():
		if i is PhysicalBone3D:
			pinned_bone = i
			if i.get_parent() is PhysicalBoneSimulator3D:
				var bones: Array[PhysicalBone3D] = []
				for bone in i.get_parent().get_children():
					if bone is PhysicalBone3D:
						bones.append(bone)
				i.owner.fall()
				#for b in bones:
					#b.apply_central_impulse(bolt.linear_velocity)
				pin.node_a = bolt.get_path()
				pin.node_b = i.get_path()
				break
				
			call_deferred("set_monitorable", false)
			call_deferred("set_monitoring", false)
