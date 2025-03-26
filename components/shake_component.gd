class_name shake_component
extends Node

@export var hurtbox_component: hurtbox_component
@export var shake_target: Node3D
@export var randomStrength: float = 3.0
@export var shakeFade: float = 5.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func _ready() -> void:
	if !hurtbox_component.is_connected("damage_taken", apply_shake):
		hurtbox_component.connect("damage_taken", apply_shake)

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shakeFade * delta)
		
		shake_target.global_position.x += rng.randf_range(-shake_strength,shake_strength)
		shake_target.global_position.z += rng.randf_range(-shake_strength,shake_strength)
		
func apply_shake(amount: float, actual: float, source: DamageComponent):
	shake_strength = randomStrength
	
func randomOffset():
	return Vector3(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))
