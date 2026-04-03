extends Label

@export var damage_type_key: DamageTypes.DAMAGE_TYPES

func _on_inventory_focused_item_changed(_item: item) -> void:
	if _item.item_stats.damage_types.has(damage_type_key):
		self.text = str(int(_item.item_stats.damage_types[damage_type_key]))
	else:
		self.text = ""
