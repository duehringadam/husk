extends Resource
class_name item

signal update_stack_size(value: int)
signal set_stack_size(value: int)

@export_category("Item Display")
@export var item_name: String
@export_multiline var item_description: String
@export var item_icon: Texture2D
@export var item_type: ItemEquippableType.ITEM_EQUIPPABLE_TYPES
@export var item_cost: int

@export_category("Item Stack")
@export var is_stackable: bool
@export_range(0,999,1.0,"or_less","prefer_slider") var max_stack_size: int = 1
@export var pick_up_stack_size: int = 1

@export_category("Item Stats")
@export var item_stats: ItemStat
@export var item_required_stats: Dictionary[ItemEquippableType.ITEM_REQUIRED_STAT, int]
@export var stamina_cost: int = 10
@export var constant_stamina_drain: int = 0
@export var mana_cost: int = 0
@export var constant_mana_drain: bool = false
@export var constant_mana_drain_cost: int = 0
@export_range(0.0,1.25) var charge_time: float = 1.0

@export_category("Item Scenes")
@export var item_scene: PackedScene
@export var item_left_scene: PackedScene
@export_file("*.tscn") var item_dropped_scene_path: String

@export_category("Misc")
@export var two_handed: bool
@export var animation_state_machine: AnimationNodeStateMachine
@export var can_be_dropped: bool = true

@export_category("Weapon_Position")
@export var position: Vector3
@export var rotation: Vector3

@export_category("Left Hand Weapon Position")
@export var left_position: Vector3
@export var left_rotation: Vector3

var unique_id: String = ""

func _init() -> void:
	update_unique_id()

func update_unique_id() -> void:
	var int_id = ResourceUID.create_id()
	unique_id = ResourceUID.id_to_text(int_id)
	
