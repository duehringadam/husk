extends RayCast3D

@onready var save_position_timer: Timer = $savePositionTimer



func _on_save_position_timer_timeout() -> void:
	if is_colliding() && !get_collider().has_meta("Unstable Ground"):
		SaveManager.save_position(get_collision_point())
