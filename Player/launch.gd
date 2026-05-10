extends ColorRect

@onready var shockwave_anim: AnimationPlayer = $shockwave
@onready var radial_blur: ColorRect = $"../radial_blur"

func _ready() -> void:
	SignalBus.connect("telekinesis_throw", shockwave)
	
func shockwave():
	radial_blur.visible = false
	self.visible = true
	shockwave_anim.play("shockwave")
