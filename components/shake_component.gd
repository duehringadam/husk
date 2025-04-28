class_name shake_component
extends Node

@export var health_component: HealthComponent
@export var hurtbox_component: hurtbox_component
@export var shake_target: Node3D
@export var randomStrength: float = .02
@export var shakeFade: float = 20


var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func _ready() -> void:
	if hurtbox_component != null:
		if !hurtbox_component.is_connected("damage_taken", apply_shake):
			hurtbox_component.connect("damage_taken", apply_shake)
	if health_component != null:
		if !health_component.is_connected("health_changed", _on_health_changed):
			health_component.connect("health_changed", _on_health_changed)	

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shakeFade * delta)
		shake_target.global_position.x += rng.randf_range(-shake_strength,shake_strength)
		shake_target.global_position.z += rng.randf_range(-shake_strength,shake_strength)
		
func _on_health_changed(amount: float, new_value: float):
	if amount > 0:
		shake_strength = randomStrength
	
func apply_shake(amount: float, actual: float, source: DamageComponent, hit_dir:Vector3):
	shake_strength = randomStrength
	
func randomOffset():
	return Vector3(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))
