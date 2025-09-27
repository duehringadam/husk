class_name status_effect
extends Resource

@export_category("Damage")
@export var effect_type: Global.STATUS_TYPE
@export var damage_types: Dictionary[DamageTypes.DAMAGE_TYPES, float]
@export var damage_component_scene: PackedScene

@export_category("Particle")
@export var status_effect_mesh: Mesh
@export var affected_target_next_pass: ShaderMaterial
@export_range(-9.8,9.8) var gravity: float
@export var turbulence: bool 
