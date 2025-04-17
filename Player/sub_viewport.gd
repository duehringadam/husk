extends SubViewport


func _on_timer_timeout() -> void:
	render_target_update_mode = SubViewport.UPDATE_ONCE
