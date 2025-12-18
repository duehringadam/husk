extends ColorRect

@onready var shockwave_anim: AnimationPlayer = $shockwave

func _ready() -> void:
	SignalBus.connect("telekinesis", shockwave)
	
func shockwave():
	shockwave_anim.play("shockwave")
