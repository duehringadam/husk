extends PanelContainer

signal focused_item_changed(_item: item)

@onready var mainhand: GridContainer = %mainhand
@onready var offhand: GridContainer = %offhand
@onready var jewelry: GridContainer = %jewelry
@onready var armor: GridContainer = %Armor
@onready var key: GridContainer = %key
@onready var consumable: GridContainer = %consumable

@onready var item_name: Label = %itemName
@onready var item_description: Label = %itemDescription
@onready var item_type: Label = %itemType


var focused_item: item

var item_add_inventory = preload("res://item_inventory.tscn")


func _ready() -> void:
	SignalBus.item_interact.connect(_update_inventory)
	

func open_inventory():
	GamePiecesEventBus.emit_signal("camera_lock_requested", true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	visible = true
	Global.player.can_attack = false

func close_inventory():
	GamePiecesEventBus.emit_signal("camera_lock_requested", false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	visible = false
	Global.player.can_attack = true


func _update_inventory(item_signal: item):
	var item_add = item_add_inventory.instantiate()
	item_add.connect("item_info", _update_display_text)
	match item_signal.item_type:
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.WEAPON:
			
			mainhand.add_child(item_add)
			item_add.item_inventory = item_signal
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.OFFHAND:
			
			offhand.add_child(item_add)
			item_add.item_inventory = item_signal
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.ARMOR:
			
			armor.add_child(item_add)
			item_add.item_inventory = item_signal
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.JEWELRY:
			
			jewelry.add_child(item_add)
			item_add.item_inventory = item_signal
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.CONSUMABLE:
			
			consumable.add_child(item_add)
			item_add.item_inventory = item_signal
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.KEY:
			
			key.add_child(item_add)
			item_add.item_inventory = item_signal


func _update_display_text(_item: item):
	focused_item = _item
	item_name.text = focused_item.item_name
	item_description.text = focused_item.item_description
	item_type.text = ItemEquippableType.ITEM_EQUIPPABLE_TYPES.keys()[focused_item.item_type]
	emit_signal("focused_item_changed", focused_item)
