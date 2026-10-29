class_name armor
extends item

@export var mesh: Mesh
@export var skin: Skin
@export var material: ShaderMaterial
@export var equip_sfx: AudioStream

@export var damage_resistances: Dictionary[DamageTypes.DAMAGE_TYPES, float] = {
	DamageTypes.DAMAGE_TYPES.STRIKE: 10,
	DamageTypes.DAMAGE_TYPES.SLASH: 10,
	DamageTypes.DAMAGE_TYPES.THRUST: 10,
	DamageTypes.DAMAGE_TYPES.MAGIC: 10,
	DamageTypes.DAMAGE_TYPES.HOLY: 10,
	DamageTypes.DAMAGE_TYPES.MURK: 10,
	DamageTypes.DAMAGE_TYPES.FIRE: 10,
	DamageTypes.DAMAGE_TYPES.POISON: 10
}

@export var status_resistances: Dictionary[Global.STATUS_TYPE, float] = {
	Global.STATUS_TYPE.BURNING: 10,
	Global.STATUS_TYPE.BLEEDING: 10,
	Global.STATUS_TYPE.SLEEP: 10,
	Global.STATUS_TYPE.POISONED: 10,
	Global.STATUS_TYPE.LEPROSY: 10
}
