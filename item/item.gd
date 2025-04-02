extends Resource
class_name item


@export var item_name: String
@export_multiline var item_description: String
@export var item_type: ItemTypes.ITEM_TYPES
@export var item_stats: Array[ItemStat]
@export var item_required_stats: Array[ItemRequiredStat]
@export var item_scene: PackedScene

func on_equip() -> void:
	on_equip_stats()

func on_unequip() -> void:
	pass

func on_equip_stats() -> void:
	pass
