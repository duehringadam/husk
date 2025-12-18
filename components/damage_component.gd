class_name DamageComponent
extends Area3D
## Component for dealing damage. Set [member amount] for simple damage,
## extend [DamageComponent] and override [method get_damage] to add
## more complex damage calculations

## Emitted when a collision with a [HurtboxComponent] occurs.
## [param amount] is the initial damage dealt.
## [param actual] is the damage after resistances are applied.
## [param target] is the [HurtboxComponent] being hit.
signal damage_dealt(types: Dictionary[DamageTypes.DAMAGE_TYPES, float], actual: float, stance_damage: float, target: hurtbox_component)

## How much damage to deal for basic attacks. Extend [DamageComponent] and
## override [method DamageComponent.get_damage] if customization is needed.
var amount: float
@export var hit_sound: AudioStream
@export var can_knockback: bool = true
@export var damage_types: Dictionary[DamageTypes.DAMAGE_TYPES, float]
@export var status_types: Dictionary[Global.STATUS_TYPE, float]
@export_range(0.0,1.0) var stance_damage_value: float
var hits: Array

## Override this to customize damage behavior (scale with velocity, etc)
func get_damage(target: hurtbox_component):
	return damage_types.values()

#func _ready() -> void:
	#connect("area_entered", self._physics_process)

func _physics_process(delta: float) -> void:
	if monitoring:
		for other in get_overlapping_areas():
			if !hits.has(other.owner):
				if other is hurtbox_component:
					hits.append(other.owner)
					var damage = get_damage(other)
					get_tree().create_timer(1).timeout.connect(func(): hits.clear())
					for i in damage:
						if i > 0:
							var actual = other.take_damage(damage_types, status_types, stance_damage_value, self)
							emit_signal("damage_dealt", damage_types, actual, stance_damage_value, other)
							AudioManager.play_sound(hit_sound, self.global_position, 0.0)
