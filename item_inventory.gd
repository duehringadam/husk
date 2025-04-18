extends PanelContainer

@export var item_inventory: item
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var item_name: RichTextLabel = $HBoxContainer/item_name
@onready var description: RichTextLabel = $HBoxContainer/description
@onready var button: Button = $HBoxContainer/Button


func _on_button_pressed() -> void:
	Global.inventory.append(Global.player.mainhand.weapon)
	match item_inventory.item_type:
			ItemTypes.ITEM_TYPES.WEAPON:
				Global.player.mainhand.weapon = item_inventory
			ItemTypes.ITEM_TYPES.OFFHAND:
				Global.player.offhand.weapon = item_inventory
			ItemTypes.ITEM_TYPES.ARMOR:
				pass
			ItemTypes.ITEM_TYPES.JEWELRY:
				pass
			ItemTypes.ITEM_TYPES.CONSUMABLE:
				pass
			ItemTypes.ITEM_TYPES.KEY:
				pass
	
