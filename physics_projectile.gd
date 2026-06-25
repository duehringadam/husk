extends RigidBody3D

@export var rotation_speed: float = 5.0
@onready var ray: RayCast3D = $RayCast3D

var target_basis


func _on_damage_component_damage_dealt(types: Dictionary, actual: float, stance_damage: float, target: hurtbox_component) -> void:
	self.queue_free()


func _on_body_entered(body: Node) -> void:
	if body is StaticBody3D:
		freeze = true
		self.global_position = ray.get_collision_point()
		self.collision_layer = 0
		get_tree().create_timer(60).timeout.connect(func(): self.queue_free())
