extends PanelContainer

@export var item_inventory: item
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var item_name: RichTextLabel = $HBoxContainer/item_name
@onready var description: RichTextLabel = $HBoxContainer/description
@onready var button: Button = $HBoxContainer/Button


func _on_button_pressed() -> void:
	Global.inventory.append(Global.player.mainhand.weapon)
	Global.player.mainhand.weapon = item_inventory
