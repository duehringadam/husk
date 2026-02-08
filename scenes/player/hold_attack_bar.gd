extends ColorRect

var is_charging: bool = false
func _ready() -> void:
	SignalBus.connect("weapon_charge_value", update_charge)
	SignalBus.connect("weapon_charge_bool", lerp_color)
	
func update_charge(value: float):
	self.visible = true
	self.material["shader_parameter/progress"] = lerpf(self.material["shader_parameter/progress"],value, .25)

func lerp_color(value: bool):
	is_charging = value

func _process(delta: float) -> void:
	if is_charging:
		self.material["shader_parameter/progress_color"] = lerp(self.material["shader_parameter/progress_color"], Color.WHITE, 2*delta)
	else:
		self.material["shader_parameter/progress_color"] = lerp(self.material["shader_parameter/progress_color"], Color(.141, .141, .141,.5),2*delta)
