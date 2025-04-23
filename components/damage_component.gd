class_name DamageComponent
extends Area3D
## Component for dealing damage. Set [member amount] for simple damage,
## extend [DamageComponent] and override [method get_damage] to add
## more complex damage calculations

## Emitted when a collision with a [HurtboxComponent] occurs.
## [param amount] is the initial damage dealt.
## [param actual] is the damage after resistances are applied.
## [param target] is the [HurtboxComponent] being hit.
signal damage_dealt(amount: float, actual: float, target: hurtbox_component, type: DamageTypes.DAMAGE_TYPES)

## How much damage to deal for basic attacks. Extend [DamageComponent] and
## override [method DamageComponent.get_damage] if customization is needed.
@export var amount: float
@export var hit_sound: AudioStream
@export var can_knockback: bool = true
@export var damage_type: DamageTypes.DAMAGE_TYPES

var hits: Array

## Override this to customize damage behavior (scale with velocity, etc)
func get_damage(target: hurtbox_component):
	return amount

#func _ready() -> void:
	#connect("area_entered", self._physics_process)

func _physics_process(delta: float) -> void:
	if monitoring:
		for other in get_overlapping_areas():
			if !hits.has(other.owner):
				if other is hurtbox_component:
					print(other.owner)
					hits.append(other.owner)
					var damage = get_damage(other)
					if damage > 0:
						var actual = other.take_damage(damage, self)
						emit_signal("damage_dealt", damage, actual, other, damage_type)
