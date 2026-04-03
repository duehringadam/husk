extends Label

enum ItemRequiredStatName {
	STRENGTH,
	WILL,
	INTELLIGENCE,
	FAITH
}

@export var required_type_key: ItemRequiredStatName

func _on_inventory_focused_item_changed(_item: item) -> void:
	if _item.item_required_stats.has(required_type_key):
		pass
