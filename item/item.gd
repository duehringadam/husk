extends Resource
class_name item


@export var item_name: String
@export_multiline var item_description: String
@export var item_type: ItemEquippableType.ITEM_EQUIPPABLE_TYPES
@export var item_stats: ItemStat
@export var item_required_stats: Dictionary[ItemEquippableType.ITEM_REQUIRED_STAT, float]
@export var item_scene: PackedScene
@export var two_handed: bool
@export var animation_state_machine: AnimationNodeStateMachine

@export_category("Weapon_Position")
@export var position: Vector3
@export var rotation: Vector3
