extends RayCast3D

@onready var save_position_timer: Timer = $savePositionTimer



func _on_save_position_timer_timeout() -> void:
	pass
	#if is_colliding() && !get_collider().has_meta("Unstable Ground"):
		#SaveConfig.set_config("Location", "Saved Position", get_collision_point())
