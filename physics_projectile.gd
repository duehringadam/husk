extends RigidBody3D

@export var rotation_speed: float = 5.0

var target_basis

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Zero out any existing physics rotational velocity
	state.angular_velocity = Vector3.ZERO
	
	state.transform.basis = target_basis
