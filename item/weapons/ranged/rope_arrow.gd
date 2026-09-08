extends PhysicsProjectile

@export var rope_to_create: PackedScene
@onready var rope_raycast: RayCast3D = $ropeRaycast
@onready var remote_transform: RemoteTransform3D = $RemoteTransform3D
@onready var rope_point: Marker3D = $rope_point
@onready var gpu_trail: GPUTrail3D = $GPUTrail3D

var rope
var target

func _ready() -> void:
	damage_component.source = Global.player

func _on_body_entered(body: Node) -> void:
	if body is StaticBody3D && body.get_meta("ground_type") == "wood":
		freeze = true
		self.global_position = other_hit_point
		self.collision_layer = 0
		damage_component.set_deferred("monitorable", false)
		damage_component.set_deferred("monitoring", false)
		call_deferred("reparent", body)
		terrain.play()
		rope = rope_to_create.instantiate()
			
		if rope_raycast.is_colliding() && rope_point.global_position.distance_to(rope_raycast.get_collision_point()) > 2:
			$rope_sound.play()
			rope.global_transform = rope_point.global_transform
			rope.number_of_segments = rope_point.global_position.distance_to(rope_raycast.get_collision_point())+1
			get_tree().current_scene.add_child(rope)
		if !rope_raycast.is_colliding():
			$rope_sound.play()
			rope.global_transform = rope_point.global_transform
			rope.number_of_segments = rope_point.global_position.distance_to(rope_point.global_position + rope_raycast.target_position)+1
			get_tree().current_scene.add_child(rope)

func _on_damage_component_damage_dealt(types: Dictionary[DamageTypes.DAMAGE_TYPES, float], actual: float, stance_damage: float, _target: hurtbox_component, slow_amount: float) -> void:
	freeze = true
	target = _target
	_pin_self()
	AudioManager.play_sound($AudioStreamPlayer3D.stream,self.global_position,0)
	damage_component.set_deferred("monitorable", false)
	damage_component.set_deferred("monitoring", false)

func _pin_self():
	var enemy_collider = target.get_child(target.local_shape_idx)
	projectile_mesh.reparent(enemy_collider)
	projectile_mesh.global_position = enemy_collider.global_position
	self.queue_free()
