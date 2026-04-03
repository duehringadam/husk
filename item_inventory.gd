extends Button

signal item_info(item_inv: item)

@export var item_inventory: item

func _on_pressed() -> void:
	match item_inventory.item_type:
			ItemEquippableType.ITEM_EQUIPPABLE_TYPES.WEAPON:
				Global.player.mainhand.weapon = item_inventory
			ItemEquippableType.ITEM_EQUIPPABLE_TYPES.OFFHAND:
				Global.player.offhand.weapon = item_inventory
			ItemEquippableType.ITEM_EQUIPPABLE_TYPES.ARMOR:
				pass
			ItemEquippableType.ITEM_EQUIPPABLE_TYPES.JEWELRY:
				pass
			ItemEquippableType.ITEM_EQUIPPABLE_TYPES.CONSUMABLE:
				pass
			ItemEquippableType.ITEM_EQUIPPABLE_TYPES.KEY:
				pass


func _on_mouse_entered() -> void:
	item_info.emit(item_inventory)
