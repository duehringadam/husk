extends ColorRect

@onready var shockwave_anim: AnimationPlayer = $shockwave

func _ready() -> void:
	SignalBus.connect("telekinesis_throw", shockwave)
	
func shockwave():
	if PlayerConfig.get_config("GameSettings", "ScreenEffects", true):
		self.visible = true
		shockwave_anim.play("shockwave")
