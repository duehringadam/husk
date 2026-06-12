extends CollisionShape3D

@export var bone_health_component: BoneHealthComponent


func bone_take_damage(damage_types: Dictionary[DamageTypes.DAMAGE_TYPES, float], actual: float):
	if bone_health_component:
					if damage_types.keys().has(DamageTypes.DAMAGE_TYPES.STRIKE):
						bone_health_component.last_damage_taken = DamageTypes.DAMAGE_TYPES.STRIKE
					if damage_types.keys().has(DamageTypes.DAMAGE_TYPES.SLASH):
						bone_health_component.last_damage_taken = DamageTypes.DAMAGE_TYPES.SLASH
					bone_health_component.modify_health(-actual)
