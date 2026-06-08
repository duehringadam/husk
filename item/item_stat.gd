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

@export_range(0,1.0) var strength_scale: float
@export_range(0,1.0) var will_scale: float
@export_range(0,1.0) var dex_scale: float
@export_range(0,1.0) var intelligence_scale: float
@export_range(0,1.0) var faith_scale: float
@export var range: float

var scaling_damage: Dictionary[DamageTypes.DAMAGE_TYPES, float]
var final_damage: Dictionary[DamageTypes.DAMAGE_TYPES, float]

func calculate_damage():
	scaling_damage.assign(damage_types)
	final_damage.assign(damage_types)
	for i in damage_types:
				match i:
					DamageTypes.DAMAGE_TYPES.STRIKE:
						scaling_damage[i] = (damage_types[i] * (strength_scale))
						final_damage[i] = scaling_damage[i] + damage_types[i]
					DamageTypes.DAMAGE_TYPES.SLASH:
						scaling_damage[i] = (damage_types[i] * (strength_scale + dex_scale))
						final_damage[i] = scaling_damage[i] + damage_types[i]
					DamageTypes.DAMAGE_TYPES.THRUST:
						scaling_damage[i] = (damage_types[i] * (strength_scale + dex_scale))
						final_damage[i] = scaling_damage[i] + damage_types[i]
					DamageTypes.DAMAGE_TYPES.MAGIC:
						scaling_damage[i] = (damage_types[i] * (intelligence_scale))
						final_damage[i] = scaling_damage[i] + damage_types[i]
					DamageTypes.DAMAGE_TYPES.HOLY:
						scaling_damage[i] = (damage_types[i] * (faith_scale))
						final_damage[i] = scaling_damage[i] + damage_types[i]
					DamageTypes.DAMAGE_TYPES.MURK:
						scaling_damage[i] = (damage_types[i] * (intelligence_scale + faith_scale))
						final_damage[i] = scaling_damage[i] + damage_types[i]
					DamageTypes.DAMAGE_TYPES.FIRE:
						scaling_damage[i] = damage_types[i]
						final_damage[i] = scaling_damage[i] + damage_types[i]
					DamageTypes.DAMAGE_TYPES.POISON:
						scaling_damage[i] = damage_types[i]
						final_damage[i] = scaling_damage[i] + damage_types[i]


func _update_player_stats(stats: Dictionary[ItemEquippableType.ITEM_REQUIRED_STAT, int]):
	for i in stats.keys():
		var x = float(stats[i])
		var n = 5.0
		match ItemEquippableType.ITEM_REQUIRED_STAT.keys()[i]:
			"STRENGTH":
				if strength_scale > 0.0:
					strength_scale += (x / (x + n))
			"DEXTERITY":
				if dex_scale > 0.0:
					dex_scale += (x / (x + n))
			"WILL":
				if will_scale > 0.0:
					will_scale += (x / (x + n))
			"INTELLIGENCE":
				if intelligence_scale > 0.0:
					intelligence_scale += (x / (x + n))
			"FAITH":
				if faith_scale > 0.0:
					faith_scale += (x / (x + n))
	
