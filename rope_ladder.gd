class_name Rope
extends Area3D

func _physics_process(delta: float) -> void:
	if Global.player != null:
		var dir = Global.player.global_position - global_position
		dir.y = 0
		dir = dir.normalized()
		rotation.y = atan2(dir.z, -dir.x)
