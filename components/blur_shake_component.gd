class_name BlurShakeAreaComponent
extends Area3D

func _physics_process(delta: float) -> void:
	if monitoring:
		for other in get_overlapping_bodies():
			if other is Player:
				SignalBus.emit_signal("raidal_blur", true, 1, get_screen_position())
				other.camera.apply_shake()

func get_screen_position() -> Vector2:
	var pos_3d = global_transform.origin
	var screen_pos = get_viewport().get_camera_3d().unproject_position(pos_3d).normalized()
	return screen_pos
	
func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		SignalBus.emit_signal("raidal_blur", false, 0, Vector2(0.5,0.5))
