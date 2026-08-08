extends Control


func _on_level_up_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	self.hide()
	self.process_mode = Node.PROCESS_MODE_DISABLED
	GamePiecesEventBus.emit_signal("camera_lock_requested", false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.player.can_attack = true
	Global.player.can_move = true
	Global.player.can_jump = true
