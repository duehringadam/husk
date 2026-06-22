extends ColorRect

@onready var complete: AudioStreamPlayer = $AudioStreamPlayer
@onready var camera: Camera3D = %Camera3D

var is_charging: bool = false
var play_sfx_once: bool = true

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
		play_sfx_once = true
		self.material["shader_parameter/progress_color"] = lerp(self.material["shader_parameter/progress_color"], Color(.141, .141, .141,.5),2*delta)
	if self.material["shader_parameter/progress"] >= .95:
		self.material["shader_parameter/progress_color"] = lerp(self.material["shader_parameter/progress_color"], Color(.141, .141, 1.0,1),10*delta)
		if play_sfx_once:
			complete.play()
			var tween = get_tree().create_tween()
			tween.tween_property(camera, "fov", camera.fov+5, .1).set_trans(Tween.TRANS_QUINT)
			play_sfx_once = false
