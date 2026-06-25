extends PanelContainer

signal focused_item_changed(_item: item)

@export var inventory: Array[item]

@export var equipped_items: Dictionary[String, item_inventory_interact]

@onready var mainhand: GridContainer = %mainhand
@onready var offhand: GridContainer = %offhand
@onready var jewelry: GridContainer = %jewelry
@onready var armor: GridContainer = %Armor
@onready var key: GridContainer = %key
@onready var consumable: GridContainer = %consumable

@onready var item_name: Label = %itemName
@onready var item_description: Label = %itemDescription
@onready var item_type: Label = %itemType
@onready var item_icon: TextureRect = %itemIcon


@onready var open: AudioStreamPlayer = %open
@onready var close: AudioStreamPlayer = %close

var focused_item: item
var item_add_inventory = preload("res://item_inventory.tscn")

func _ready() -> void:
	SignalBus.item_interact.connect(_update_inventory)
	SignalBus.remove_item.connect(_remove_item)
	

func open_inventory():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1,.1).set_trans(Tween.TRANS_SINE)
	tween.parallel()
	tween.tween_property(self, "position", Vector2.ZERO, .1).set_trans(Tween.TRANS_SINE)
	open.play()
	GamePiecesEventBus.emit_signal("camera_lock_requested", true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	visible = true
	Global.player.can_attack = false

func close_inventory():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0,.1).set_trans(Tween.TRANS_SINE)
	tween.parallel()
	tween.tween_property(self, "position", Vector2(0,20), .1).set_trans(Tween.TRANS_SINE)
	close.play()
	GamePiecesEventBus.emit_signal("camera_lock_requested", false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.player.can_attack = true
	await tween.finished
	visible = false
	

func _update_inventory(item_signal: item):
	var item_add = item_add_inventory.instantiate()
	item_add.connect("item_info", _update_display_text)
	item_add.connect("item_drop", _drop_item)
	if !SignalBus.is_connected("player_stats_changed", item_signal.item_stats._update_player_stats):
		SignalBus.connect("player_stats_changed", item_signal.item_stats._update_player_stats)
	if !item_add.is_connected("equipped_signal",_update_equipped_items):
		item_add.connect("equipped_signal", _update_equipped_items)
	item_signal.item_stats._update_player_stats(Global.player.player_stats)
	
	match item_signal.item_type:
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.WEAPON:
			mainhand.add_child(item_add)
			item_add.item_inventory = item_signal
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.OFFHAND:
			if inventory.has(item_signal):
				var stackable_offhand: int = inventory.find(item_signal)
				if inventory[stackable_offhand].is_stackable:
					inventory[stackable_offhand]._update_stack_size(1)
			else:
				offhand.add_child(item_add)
				item_add.item_inventory = item_signal
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.ARMOR:
			armor.add_child(item_add)
			item_add.item_inventory = item_signal
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.JEWELRY:
			jewelry.add_child(item_add)
			item_add.item_inventory = item_signal
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.CONSUMABLE:
			if inventory.has(item_signal):
				var consumable_item: int = inventory.find(item_signal)
				if inventory[consumable_item].is_stackable:
					inventory[consumable_item]._update_stack_size(1)
			else:
				consumable.add_child(item_add)
				item_add.item_inventory = item_signal
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.KEY:
			key.add_child(item_add)
			item_add.item_inventory = item_signal
	inventory.append(item_signal)

func _update_equipped_items(item_inv_interact: item_inventory_interact):
	match item_inv_interact.item_inventory.item_type:
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.WEAPON:
			if equipped_items["mainhand_equipped"] != null:
				equipped_items["mainhand_equipped"].is_equipped = false
			equipped_items["mainhand_equipped"] = item_inv_interact
			item_inv_interact.is_equipped = true
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.OFFHAND:
			if equipped_items["offhand_equipped"] != null:
				equipped_items["offhand_equipped"].is_equipped = false
			equipped_items["offhand_equipped"] = item_inv_interact
			item_inv_interact.is_equipped = true
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.ARMOR:
			if equipped_items["armor_equipped"] != null:
				equipped_items["armor_equipped"].is_equipped = false
			equipped_items["armor_equipped"] = item_inv_interact
			item_inv_interact.is_equipped = true
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.JEWELRY:
			if equipped_items["jewelry_equipped"] != null:
				equipped_items["jewelry_equipped"].is_equipped = false
			equipped_items["jewelry_equipped"] = item_inv_interact
			item_inv_interact.is_equipped = true

func _remove_item(item_inventory: item):
	if inventory.has(item_inventory):
		inventory.erase(item_inventory)
		

func _drop_item(item_to_drop: item):
	var item_drop = item_to_drop.item_dropped_scene.instantiate()
	get_tree().current_scene.add_child(item_drop)
	item_drop.global_position = Global.player.camera.global_position + (-Global.player.camera.global_transform.basis.z.normalized()*1.5)

func _update_display_text(_item: item):
	focused_item = _item
	item_name.text = focused_item.item_name
	item_description.text = focused_item.item_description
	item_type.text = ItemEquippableType.ITEM_EQUIPPABLE_TYPES.keys()[focused_item.item_type]
	item_icon.texture = focused_item.item_icon
	emit_signal("focused_item_changed", focused_item)
