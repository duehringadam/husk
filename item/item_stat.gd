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

@export_category("Base Scaling Values")
@export_range(0,1.0) var strength_scale: float
@export_range(0,1.0) var will_scale: float
@export_range(0,1.0) var dex_scale: float
@export_range(0,1.0) var intelligence_scale: float
@export_range(0,1.0) var faith_scale: float

@export_category("Scaling Curve Overrides")
@export var strength_scaling_curve_override: Curve
@export var will_scaling_curve_override: Curve
@export var dex_scaling_curve_override: Curve
@export var intelligence_scaling_curve_override: Curve
@export var faith_scaling_curve_override: Curve

@export var range: float

var strength_scaling_curve: Curve
var will_scaling_curve: Curve
var dex_scaling_curve: Curve
var intelligence_scaling_curve: Curve
var faith_scaling_curve: Curve

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
		match ItemEquippableType.ITEM_REQUIRED_STAT.keys()[i]:
			"STRENGTH":
				if strength_scale > 0.0:
					if !strength_scaling_curve_override:
						strength_scaling_curve = assign_scaling_curve(strength_scale)
					else:
						strength_scaling_curve = strength_scaling_curve_override
					strength_scale += strength_scaling_curve.sample(stats[i]/100.0)
			"DEXTERITY":
				if dex_scale > 0.0:
					if !dex_scaling_curve_override:
						dex_scaling_curve = assign_scaling_curve(dex_scale)
					else:
						dex_scaling_curve = strength_scaling_curve_override
					dex_scale += dex_scaling_curve.sample(stats[i]/100.0)
			"WILL":
				if will_scale > 0.0:
					if !will_scaling_curve_override:
						will_scaling_curve = assign_scaling_curve(will_scale)
					else:
						will_scaling_curve = will_scaling_curve_override
					will_scale += will_scaling_curve.sample(stats[i]/100.0)
			"INTELLIGENCE":
				if intelligence_scale > 0.0:
					if !intelligence_scaling_curve_override:
						intelligence_scaling_curve = assign_scaling_curve(intelligence_scale)
					else:
						intelligence_scaling_curve = intelligence_scaling_curve_override
					intelligence_scale += intelligence_scaling_curve.sample(stats[i]/100.0)
			"FAITH":
				if faith_scale > 0.0:
					if !faith_scaling_curve_override:
						faith_scaling_curve = assign_scaling_curve(faith_scale)
					else:
						faith_scaling_curve = faith_scaling_curve_override
					faith_scale += faith_scaling_curve.sample(stats[i]/100.0)
	

func assign_scaling_curve(base_scale: float) -> Curve:
	if base_scale > 0.0 && base_scale < .51:
		return load("res://item/weapons/scaling_curves/weapon_scaling_curve_d.tres")
	if base_scale > .5 && base_scale < .66:
		return load("res://item/weapons/scaling_curves/weapon_scaling_curve_c.tres")
	if base_scale > .65 && base_scale < .76:
		return load("res://item/weapons/scaling_curves/weapon_scaling_curve_b.tres")
	if base_scale > .75 && base_scale < .86:
		return load("res://item/weapons/scaling_curves/weapon_scaling_curve_a.tres")
	return load("res://item/weapons/scaling_curves/weapon_scaling_curve_s.tres")
	
