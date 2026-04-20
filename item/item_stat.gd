class_name ItemStat
extends Resource

enum ItemStatName {
	STRENGTH_SCALE,
	WILL_SCALE,
	INTELLIGENCE_SCALE,
	FAITH_SCALE
}

@export var damage_types: Dictionary[DamageTypes.DAMAGE_TYPES, float]
@export_range(0.0,1.0) var stance_damage: float
@export_range(0, 10) var upgrade_levels: int
@export var strength_scale: float
@export var will_scale: float
@export var intelligence_scale: float
@export var faith_scale: float
@export var range: float


func calculate_damage():
	for i in damage_types:
				match i:
					DamageTypes.DAMAGE_TYPES.STRIKE:
						damage_types[i] = (damage_types[i] * (1.0 + strength_scale))
					DamageTypes.DAMAGE_TYPES.SLASH:
						damage_types[i] = (damage_types[i] * (1.0 + strength_scale))
					DamageTypes.DAMAGE_TYPES.THRUST:
						damage_types[i] = (damage_types[i] * (1.0 + will_scale))
					DamageTypes.DAMAGE_TYPES.MAGIC:
						damage_types[i] = (damage_types[i] * (1.0 + intelligence_scale))
					DamageTypes.DAMAGE_TYPES.HOLY:
						damage_types[i] = (damage_types[i] * (1.0 + faith_scale))
					DamageTypes.DAMAGE_TYPES.MURK:
						damage_types[i] = (damage_types[i] * (1.0 + intelligence_scale + faith_scale))
					DamageTypes.DAMAGE_TYPES.FIRE:
						damage_types[i] = damage_types[i]
					DamageTypes.DAMAGE_TYPES.POISON:
						damage_types[i] = damage_types[i]
