class_name npc_weapon
extends Resource

@export_category("Main Weapon")
@export var main_weapon_scene: PackedScene
@export var main_weapon_offhand_scene: PackedScene
@export var main_weapon_animation_state_machine: AnimationNodeStateMachine

@export_category("Main Transform")
@export var main_weapon_position: Vector3
@export var main_weapon_rotation: Vector3
@export var main_weapon_scale: Vector3 = Vector3.ONE

@export_category("Offhand transform")
@export var main_weapon_offhand_position: Vector3
@export var main_weapon_offhand_rotation: Vector3
@export var main_weapon_offhand_scale: Vector3 = Vector3.ONE


@export_category("Secondary Weapon")
@export var secondary_weapon_scene: PackedScene
@export var secondary_weapon_offhand_scene: PackedScene
@export var secondary_weapon_animation_state_machine: AnimationNodeStateMachine

@export_category("Secondary Transform")
@export var secondary_weapon_position: Vector3
@export var secondary_weapon_rotation: Vector3
@export var secondary_weapon_scale: Vector3 = Vector3.ONE

@export_category("Secondary Offhand Transform")
@export var secondary_weapon_offhand_position: Vector3
@export var secondary_weapon_offhand_rotation: Vector3
@export var secondary_weapon_offhand_scale: Vector3 = Vector3.ONE
