extends Offhand

var primary_active_bool: bool = false

func _ready() -> void:
	equip_sound.play()

func activate():
	SignalBus.emit_signal("is_blocking", true)
	activate_sound.pitch_scale = randf_range(.9,1.2)
	activate_sound.play()

func deactivate():
	SignalBus.emit_signal("is_blocking", false)
	activate_sound.pitch_scale = randf_range(.9,1.2)
	activate_sound.play()
