extends Resource
class_name item

signal stack_size_changed(amount: int)

@export_category("Item Display")
@export var item_name: String
@export_multiline var item_description: String
@export var item_icon: Texture2D
@export var item_type: ItemEquippableType.ITEM_EQUIPPABLE_TYPES

@export_category("Item Stack")
@export var is_stackable: bool
@export_range(0,999,1.0,"or_less","prefer_slider") var max_stack_size: int
@export var current_stack_size: int

@export_category("Item Stats")
@export var item_stats: ItemStat
@export var item_required_stats: Dictionary[ItemEquippableType.ITEM_REQUIRED_STAT, int]
@export var stamina_cost: int = 10
@export var mana_cost: int = 0
@export var constant_mana_drain: bool = false
@export var constant_mana_drain_cost: int = 0
@export_range(0.0,1.25) var charge_time: float = 1.0

@export_category("Item Scenes")
@export var item_scene: PackedScene
@export var item_left_scene: PackedScene
@export var item_dropped_scene: PackedScene

@export_category("Misc")
@export var two_handed: bool
@export var animation_state_machine: AnimationNodeStateMachine

@export_category("Weapon_Position")
@export var position: Vector3
@export var rotation: Vector3

@export_category("Left Hand Weapon Position")
@export var left_position: Vector3
@export var left_rotation: Vector3


func _update_stack_size(amount: int):
	current_stack_size = clampi(current_stack_size+amount, 0, max_stack_size)
	stack_size_changed.emit(current_stack_size)
