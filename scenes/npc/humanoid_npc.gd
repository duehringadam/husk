class_name humanoid_npc
extends npc

@export var mainhand: BoneAttachment3D
@export var offhand: BoneAttachment3D

@export_category("Weapons")
@export var main_weapon: npc_weapon: set = _update_main_weapon
@export var secondary_weapon: npc_weapon: set = _update_secondary_weapon


@export_category("Animation State Machine")
@export var current_animation_state_machine: AnimationNodeStateMachine

@export_category("Infestation")
@export var is_infested: bool = false
@export var infestation_bone_attach: infestation_attach
@export var infestation_enemy_scene: PackedScene

var secondary_weapon_active: bool = false: set = _update_secondary_weapon_active

var main_weapon_add
var main_weapon_offhand_add
var secondary_weapon_add
var secondary_weapon_offhand_add
var is_blocking: bool = false: set = _update_blocking
var has_shield: bool = false

func _update_blocking(value: bool):
	pass

func _update_main_weapon(weapon: npc_weapon):
	if weapon == null:return
	await ready
	main_weapon = weapon
	animation_tree.tree_root = weapon.main_weapon_animation_state_machine
	if weapon.main_weapon_scene != null:
		main_weapon_add = weapon.main_weapon_scene.instantiate()
		main_weapon_add.position = weapon.main_weapon_position
		main_weapon_add.rotation = weapon.main_weapon_rotation
		main_weapon_add.scale = weapon.main_weapon_scale
		main_weapon_add.damage_component.source = self
		mainhand.add_child(main_weapon_add)
		main_weapon_add.owner = self
		
	if weapon.main_weapon_offhand_scene != null:
		main_weapon_offhand_add = weapon.main_weapon_offhand_scene.instantiate()
		main_weapon_offhand_add.position = weapon.main_weapon_offhand_position
		main_weapon_offhand_add.rotation = weapon.main_weapon_offhand_rotation
		main_weapon_offhand_add.scale = weapon.main_weapon_offhand_scale
		main_weapon_offhand_add.damage_component.source = self
		offhand.add_child(main_weapon_offhand_add)
		main_weapon_offhand_add.owner = self
	
	if weapon.main_weapon_animation_state_machine.has_node("walkBlendTree"):
		var walk_blend = weapon.main_weapon_animation_state_machine.get_node("walkBlendTree")
		var shield_walk_blend = walk_blend.get_node("shieldWalkBlend")
		if shield_walk_blend != null:
			has_shield = true
		else:
			has_shield = false

func _update_secondary_weapon(weapon: npc_weapon):
	if weapon == null: return
	secondary_weapon = weapon
	
	if weapon.secondary_weapon_scene != null:
		secondary_weapon_add = weapon.secondary_weapon_scene.instantiate()
		secondary_weapon_add.position = weapon.secondary_weapon_position
		secondary_weapon_add.rotation = weapon.secondary_weapon_rotation
		secondary_weapon_add.scale = weapon.secondary_weapon_scale
		
		mainhand.add_child(secondary_weapon_add)
	
	if weapon.secondary_weapon_offhand_scene != null:
		secondary_weapon_offhand_add = weapon.secondary_weapon_offhand_scene.instantiate()
		secondary_weapon_offhand_add.position = weapon.secondary_weapon_offhand_position
		secondary_weapon_offhand_add.rotation = weapon.secondary_weapon_offhand_rotation
		secondary_weapon_offhand_add.scale = weapon.secondary_weapon_offhand_scale
	
		offhand.add_child(secondary_weapon_offhand_add)

func _update_is_infested(value: bool):
	pass
	
func _update_secondary_weapon_active(value: bool):
	secondary_weapon_active = value
	_update_main_weapon_visibility(!value)
	_update_secondary_weapon_visibility(value)

func _update_main_weapon_visibility(value: bool):
	main_weapon_add.visible = value
	main_weapon_offhand_add.visible = value

func _update_secondary_weapon_visibility(value: bool):
	secondary_weapon_add.visible = value
	secondary_weapon_offhand_add.visible = value

func activate_mainhand_weapon(value: bool):
	if value:
		main_weapon_add.activate()
	else:
		main_weapon_add.deactivate()
	
func activate_main_offhand_weapon(value: bool):
	if value:
		main_weapon_offhand_add.activate()
	else:
		main_weapon_offhand_add.deactivate()

func activate_secondary_weapon(value: bool):
	if value:
		secondary_weapon_add.activate()
	else:
		secondary_weapon_add.deactivate()

func activate_secondary_offhand_weapon(value: bool):
	if value:
		secondary_weapon_offhand_add.activate()
	else:
		secondary_weapon_offhand_add.deactivate()
