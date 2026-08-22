class_name Shop
extends Control

signal focused_item_changed(_item: item)

@export var shop_inventory: Array[item]
@export var shop_containers: Array[GridContainer]

@onready var mainhand: GridContainer = %mainhand
@onready var offhand: GridContainer = %offhand
@onready var jewelry: GridContainer = %jewelry
@onready var armor: GridContainer = %Armor
@onready var key: GridContainer = %key
@onready var consumable: GridContainer = %consumable
@onready var item_list_tabs: TabContainer = %itemListTabs

@onready var item_name: Label = %itemName
@onready var item_description: Label = %itemDescription
@onready var item_type: Label = %itemType
@onready var item_icon: TextureRect = %itemIcon

@onready var open: AudioStreamPlayer = %open
@onready var close: AudioStreamPlayer = %close

var focused_item: item
var item_add_inventory = preload("res://Player/UI/inventory/item_shop_inventory.tscn")
var is_open: bool = false

func _ready() -> void:
	update_shop_list()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory") && is_open:
		close_shop()

func update_shop_list():
	for items in shop_inventory:
		_update_inventory(items)

func open_shop():
	is_open = !is_open
	visible = is_open
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1,.25).set_trans(Tween.TRANS_SINE)
	tween.parallel()
	tween.tween_property(self, "offset_transform_position", Vector2.ZERO, .25).set_trans(Tween.TRANS_SINE)
	open.play()

func close_shop():
	is_open = !is_open
	visible = is_open
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0,.25).set_trans(Tween.TRANS_SINE)
	tween.parallel()
	tween.tween_property(self, "offset_transform_position", Vector2(0,30), .25).set_trans(Tween.TRANS_SINE)
	close.play()
	await tween.finished
	

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
	item_icon.texture = focused_item.item_icon
	emit_signal("focused_item_changed", focused_item)

func _on_exit_pressed() -> void:
	close_shop()
