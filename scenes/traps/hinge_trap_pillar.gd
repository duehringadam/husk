extends MeshInstance3D


func _on_health_component_died() -> void:
	self.queue_free()
