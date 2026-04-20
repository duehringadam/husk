extends Offhand

var primary_active_bool: bool = false
@onready var raise: AudioStreamPlayer3D = $Cube/raise
@onready var equip: AudioStreamPlayer3D = $equip


func _ready() -> void:
	equip.play()

func activate():
	SignalBus.emit_signal("is_blocking", true)
	raise.pitch_scale = randf_range(.9,1.2)
	raise.play()

func deactivate():
	SignalBus.emit_signal("is_blocking", false)
	raise.pitch_scale = randf_range(.9,1.2)
	raise.play()
