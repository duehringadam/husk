extends ColorRect

@export_range(0,0.01) var blur_amount: float
var blur: bool = false
func _ready() -> void:
	SignalBus.connect("raidal_blur", _update_blur)
	

func _update_blur(value: bool):
	blur = value
		
func _process(delta: float) -> void:
	if blur:
		self.material["shader_parameter/blur_power"] = lerpf(self.material["shader_parameter/blur_power"],blur_amount,4*delta)
	else:
		self.material["shader_parameter/blur_power"] = lerpf(self.material["shader_parameter/blur_power"],0,4*delta)


func _on_hurtbox_component_damage_taken(actual: float, source: DamageComponent, hit_dir: Vector3) -> void:
	blur = true
	await get_tree().create_timer(.5).timeout
	blur = false
