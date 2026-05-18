extends Node3D

@export var trigger_explosion: bool = false : set = _set_trigger_explosion

@export var shockwave_node: MeshInstance3D
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var damage_component: DamageComponent = $DamageComponent
@onready var scorch_decal: Decal = $ScorchDecal

var _shockwave_tween: Tween
var _scorch_tween: Tween
var hits: Array

func _ready() -> void:
	animation_player.play("explode")
	if global_position.distance_to(Global.player.global_position) < 3:
		Global.player.camera.apply_shake()
	if has_node("ScorchDecal"):
		$ScorchDecal.albedo_mix = 0.0

func _physics_process(delta: float) -> void:
	if damage_component.monitoring:
			for i in damage_component.get_overlapping_bodies():
				if i is RigidBody3D or i is PhysicalBone3D:
					if !hits.has(i):
						hits.append(i)
						i.apply_central_impulse((i.global_position - self.global_position).normalized() * 50 * i.mass)


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


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	self.queue_free()


func _on_damage_component_damage_dealt(types: Dictionary, actual: float, stance_damage: float, target: hurtbox_component) -> void:
	if target.get_parent() is PhysicalBone3D:
		target.get_parent().apply_central_impulse((target.get_parent().global_position - self.global_position).normalized() * 350 * target.get_parent().mass)
