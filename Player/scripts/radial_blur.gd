extends ColorRect

@export_range(0,0.01) var blur_amount: float
@export var blur: bool = false

@onready var launch: ColorRect = $"../launch"
@onready var blur_timer: Timer = %blurTimer

func _ready() -> void:
	SignalBus.connect("raidal_blur", _update_blur)

func _update_blur(value: bool, duration: float = 1, blur_center: Vector2 = Vector2(0.5,0.5)):
	if PlayerConfig.get_config("GameSettings", "ScreenEffects", true):
		blur = value
		if value:
			launch.visible = false
			self.visible = true
			blur_timer.wait_time = duration
			blur_timer.start()
			self.material["shader_parameter/blur_center"] = blur_center
	else:
		blur = false
func _process(delta: float) -> void:
	if blur:
		self.material["shader_parameter/blur_power"] = lerpf(self.material["shader_parameter/blur_power"],blur_amount,4*delta)
	else:
		self.material["shader_parameter/blur_power"] = lerpf(self.material["shader_parameter/blur_power"],0,4*delta)


func _on_blur_timer_timeout() -> void:
	blur = false
