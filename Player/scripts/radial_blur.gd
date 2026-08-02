extends ColorRect

@export_range(0,0.01) var blur_amount: float
@export var blur: bool = false
@onready var launch: ColorRect = $"../launch"

func _ready() -> void:
	SignalBus.connect("raidal_blur", _update_blur)

func _update_blur(value: bool):
	if PlayerConfig.get_config("GameSettings", "ScreenEffects", true):
		blur = value
		if value:
			launch.visible = false
			self.visible = true
	else:
		blur = false
func _process(delta: float) -> void:
	if blur:
		self.material["shader_parameter/blur_power"] = lerpf(self.material["shader_parameter/blur_power"],blur_amount,4*delta)
	else:
		self.material["shader_parameter/blur_power"] = lerpf(self.material["shader_parameter/blur_power"],0,4*delta)
