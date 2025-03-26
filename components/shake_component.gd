class_name shake_component
extends Node

@export var hurtbox_component: hurtbox_component

@export var shake_reduction_rate: float = .1
@export var shake_amount: float = 0.0
@export var shake_target: Node3D


var shake: bool = false
var initial_pos: Vector3

func _ready() -> void:
	if !hurtbox_component.is_connected("damage_taken", apply_shake):
		hurtbox_component.connect("damage_taken", apply_shake)

@export var randomStrength: float = 3.0
@export var shakeFade: float = 5.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
	
func _process(delta: float) -> void:
	
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shakeFade * delta)
		
		shake_target.global_position.x += rng.randf_range(-shake_strength,shake_strength)
		shake_target.global_position.z += rng.randf_range(-shake_strength,shake_strength)
		
func apply_shake(amount: float, actual: float, source: DamageComponent):
	shake_strength = randomStrength
	

func randomOffset():
	return Vector3(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))
