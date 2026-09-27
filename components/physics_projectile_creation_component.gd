extends Node3D

@export var projectile_scene: PackedScene
@export var projectile_speed: float
@export_flags_3d_physics var damage_mask_layers: int

var target_node: Node3D

func create_projectile():
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	
	projectile.global_position = self.global_position
	
	var throw_direction = (target_node.global_position - self.global_position).normalized()
	
	if throw_direction != Vector3.ZERO:
		projectile.look_at(self.global_position + throw_direction, Vector3.UP)
	
	if "impact_dir" in projectile:
		projectile.impact_dir = throw_direction
		
	if projectile.damage_component != null:
		projectile.damage_component.collision_mask = damage_mask_layers
		
	projectile.apply_central_impulse(throw_direction * projectile_speed)
	projectile.apply_torque(Vector3(0, 0, 1.0))



func _on_vision_area_max_aggro(_aggro_amount: float, aggro_node: Node3D) -> void:
	target_node = aggro_node
