extends PanelContainer

@export var item_inventory: item
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var item_name: RichTextLabel = $HBoxContainer/item_name
@onready var description: RichTextLabel = $HBoxContainer/description
@onready var button: Button = $HBoxContainer/Button


func _on_button_pressed() -> void:
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
	
