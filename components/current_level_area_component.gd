extends Area3D

@export var default_spawn_node: Marker3D

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.current_area_default_spawn = default_spawn_node.global_position
