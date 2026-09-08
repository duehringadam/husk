class_name PhysicsProjectile
extends RigidBody3D

@export var terrain: AudioStreamPlayer3D
@export var damage_component: DamageComponent
@export var projectile_mesh: MeshInstance3D

var target_basis
var other_hit_point
var local_hit_point

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() > 0:
		for i in range(state.get_contact_count()):
			other_hit_point = state.get_contact_collider_position(i)
			local_hit_point = state.get_contact_local_position(i)
			var normal = state.get_contact_local_normal(i) #if you want to align projectile to normal of what it hits


func _on_body_entered(body: Node) -> void:
	if body is StaticBody3D:
		freeze = true
		self.global_position = other_hit_point
		self.collision_layer = 0
		damage_component.set_deferred("monitorable", false)
		damage_component.set_deferred("monitoring", false)
		call_deferred("reparent", body)
		terrain.play()
		get_tree().create_timer(60).timeout.connect(func(): self.queue_free())


func _on_damage_component_damage_dealt(types: Dictionary[DamageTypes.DAMAGE_TYPES, float], actual: float, stance_damage: float, target: hurtbox_component, slow_amount: float) -> void:
	damage_component.set_deferred("monitorable", false)
	damage_component.set_deferred("monitoring", false)
