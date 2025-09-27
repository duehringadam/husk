extends SubViewport

var timer = 0

#func _process(delta: float) -> void:
	#timer += delta
	#if timer >= 0.03:
		#render_target_update_mode = SubViewport.UPDATE_ONCE
		#timer = 0
