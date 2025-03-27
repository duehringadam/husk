class_name hurtbox_component
extends Area3D

signal damage_taken(amount: float, actual: float, source: DamageComponent)

@onready var timer: Timer

@export var damage_resistance: DamageTypes.DAMAGE_TYPES

## Where to apply incoming damage
@export var health_component: HealthComponent

## Reduction on incoming damage. Zero takes full damage, one takes none. For more complex behavior, override [method reduce_damage]
@export_range(0, 1) var damage_resist: float
@export var invulnerability_duration: float
@export var damage_particles: PackedScene


## add the invulnerability timer
func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	SignalBus.connect("player_immune",invulnerability)
	
## start the invulnerability timer
func invulnerability(duration: float):
	timer.start(duration)

## Override this to cusomize damage reduction (damage types, armor, etc)
func reduce_damage(amount: float, source: DamageComponent) -> float:
	return amount * (1 - damage_resist)

func take_damage(amount: float, source: DamageComponent):
	if timer.time_left > 0: return 0
	
	# invulnerability on damage
	invulnerability(invulnerability_duration)
	# take damage
	var actual = reduce_damage(amount, source)
	emit_signal("damage_taken", amount, actual, source)
	health_component.modify_health(-actual)
	return actual
