@tool
extends Node3D

@export var trigger_explosion: bool = false : set = _set_trigger_explosion

@export var shockwave_node: MeshInstance3D

var _shockwave_tween: Tween
var _scorch_tween: Tween


func _ready() -> void:
	if has_node("ScorchDecal"):
		$ScorchDecal.albedo_mix = 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_home"):
		_set_trigger_explosion(true)


func _set_trigger_explosion(value: bool) -> void:
	if value:
		for child in get_children():
			if child is GPUParticles3D:
				child.restart()
		_trigger_shockwave()
		_animate_scorch()
	trigger_explosion = false

func _animate_scorch() -> void:
	if not has_node("ScorchDecal"):
		return
	if _scorch_tween:
		_scorch_tween.kill()
	var scorch = $ScorchDecal
	scorch.albedo_mix = 0.0
	_scorch_tween = create_tween()
	_scorch_tween.tween_property(scorch, "albedo_mix", 1.0, 0.2)
	_scorch_tween.tween_property(scorch, "albedo_mix", 0.0, 4.0).set_delay(2.0)

func _trigger_shockwave() -> void:
	if _shockwave_tween:
		_shockwave_tween.kill()
	shockwave_node.visible = true
	if is_inside_tree():
		_shockwave_tween = create_tween()
		shockwave_node.material_override.set_shader_parameter("progress", 0.0)
		_shockwave_tween.tween_property(shockwave_node.material_override, "shader_parameter/progress", 0.75, 0.75)
		
		_shockwave_tween.finished.connect(func(): shockwave_node.visible = false)
