extends TabContainer

#func _ready() -> void:
	#SignalBus.connect("player_ready", player_ready)

func _on_button_pressed() -> void:
	self.hide()
	GamePiecesEventBus.emit_signal("camera_lock_requested", false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func player_ready():
	await get_tree().create_timer(.1).timeout
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GamePiecesEventBus.emit_signal("camera_lock_requested", true)
	self.show()
