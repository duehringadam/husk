@tool
extends PanelContainer

signal focused_item_changed(_item: item)


@export var inventory: Array[Dictionary]

@export var equipped_items: Dictionary[String, item_inventory_interact]

@onready var mainhand: GridContainer = %mainhand
@onready var offhand: GridContainer = %offhand
@onready var jewelry: GridContainer = %jewelry
@onready var armor: GridContainer = %Armor
@onready var key: GridContainer = %key
@onready var consumable: GridContainer = %consumable
@onready var inventory_tabs: TabBar = %inventoryTabs
@onready var item_list_tabs: TabContainer = %itemListTabs

@onready var item_name: Label = %itemName
@onready var item_description: Label = %itemDescription
@onready var item_type: Label = %itemType
@onready var item_icon: TextureRect = %itemIcon

@onready var quickselect: Button = %quickselect
@onready var quickselect_2: Button = %quickselect2
@onready var quickselect_3: Button = %quickselect3
@onready var quickselect_4: Button = %quickselect4
@onready var mainhand_button: Button = %mainhand_button
@onready var offhand_button: Button = %offhand_button
@onready var ammo_button: Button = %ammo_button
@onready var jewelry_button: Button = %jewelry_button
@onready var leg_button: Button = %leg_button
@onready var chest_button: Button = %chest_button


@onready var equipment: NinePatchRect = %equipment
@onready var inventory_list_container: PanelContainer = %inventory_list_container
@onready var item_list: NinePatchRect = %itemList
@onready var item_info: NinePatchRect = %itemInfo
@onready var player_stats: NinePatchRect = %playerStats
@onready var drop_amount_pop_up: MarginContainer = $dropAmountPopUp


@onready var open: AudioStreamPlayer = %open
@onready var close: AudioStreamPlayer = %close

var focused_item: item
var item_add_inventory = preload("res://Player/UI/inventory/item_inventory.tscn")
var transition_from_equip_screen: bool = false

var item_save_file_path: String = "res://item/save_file_resources/"

func _ready() -> void:
	SignalBus.item_interact.connect(_update_inventory)
	SignalBus.remove_item.connect(_remove_item)
	

func open_inventory():
	%inventoryTabs.focus_mode = FOCUS_ALL
	%inventoryTabs.grab_focus()
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
	
func save_inventory():
	SaveManager.set_inventory("Saved Inventory", inventory)

func _update_inventory(item_signal: item):
	var item_add = item_add_inventory.instantiate()
	item_add.connect("item_info", _update_display_text)
	item_add.connect("item_drop", _drop_item)
	item_add.connect("stack_size_changed", save_inventory)
	item_add.name = item_signal.item_name
	if !SignalBus.is_connected("player_stats_changed", item_signal.item_stats._update_player_stats):
		SignalBus.connect("player_stats_changed", item_signal.item_stats._update_player_stats)
	if !item_add.is_connected("equipped_signal",_update_equipped_items):
		item_add.connect("equipped_signal", _update_equipped_items)
	item_signal.item_stats._update_player_stats(Global.player.player_stats)
	
	var item_exists: bool
	var item_index: int
	
	for _item in inventory:
		if _item.get(item_signal) != null:
			item_exists = true
			item_index = inventory.find(_item)
	
	match item_signal.item_type:
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.WEAPON:
			mainhand.add_child(item_add)
			item_add.item_inventory = item_signal
			var item_dict: Dictionary
			item_dict[item_signal] = item_signal.pick_up_stack_size
			inventory.append(item_dict)
			save_inventory()
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.OFFHAND:
			if item_exists && item_signal.is_stackable:
				var item_to_find = offhand.find_child(item_signal.item_name, false, false)
				if item_to_find:
					if !item_to_find.is_connected("stack_size_changed",save_inventory):
						item_to_find.connect("stack_size_changed", save_inventory)
					item_to_find.update_stack_size(item_signal.pick_up_stack_size)
					inventory[item_index][item_signal] += item_signal.pick_up_stack_size
			if !item_exists:
				offhand.add_child(item_add)
				item_add.item_inventory = item_signal
				item_add.item_stack_size = item_signal.pick_up_stack_size
				var item_dict: Dictionary
				item_dict[item_signal] = item_signal.pick_up_stack_size
				inventory.append(item_dict)
				save_inventory()
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.ARMOR:
			armor.add_child(item_add)
			item_add.item_inventory = item_signal
			var item_dict: Dictionary
			item_dict[item_signal] = item_signal.pick_up_stack_size
			inventory.append(item_dict)
			save_inventory()
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.JEWELRY:
			jewelry.add_child(item_add)
			item_add.item_inventory = item_signal
			var item_dict: Dictionary
			item_dict[item_signal] = item_signal.pick_up_stack_size
			inventory.append(item_dict)
			save_inventory()
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.CONSUMABLE:
			if item_exists && item_signal.is_stackable:
				var item_to_find = consumable.find_child(item_signal.item_name, false, false)
				if item_to_find:
					item_to_find.connect("stack_size_changed", save_inventory)
					item_to_find.update_stack_size(item_signal.pick_up_stack_size)
					inventory[item_index][item_signal] += item_signal.pick_up_stack_size
			else:
				consumable.add_child(item_add)
				item_add.item_inventory = item_signal
				item_add.item_stack_size = item_signal.pick_up_stack_size
				var item_dict: Dictionary
				item_dict[item_signal] = item_signal.pick_up_stack_size
				inventory.append(item_dict)
				save_inventory()
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.KEY:
			if inventory.has(item_signal):
				item_signal = item_signal.duplicate()
			key.add_child(item_add)
			item_add.item_inventory = item_signal
			var item_dict: Dictionary
			item_dict[item_signal] = item_signal.pick_up_stack_size
			inventory.append(item_dict)
			save_inventory()
	
func _update_equipped_items(item_inv_interact: item_inventory_interact):
	match item_inv_interact.item_inventory.item_type:
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.WEAPON:
			if equipped_items["mainhand_equipped"] != null:
				equipped_items["mainhand_equipped"].is_equipped = false
			equipped_items["mainhand_equipped"] = item_inv_interact
			mainhand_button.icon = item_inv_interact.item_inventory.item_icon
			item_inv_interact.is_equipped = true
			if item_inv_interact.item_inventory.two_handed:
				offhand_button.icon = null
				equipped_items["offhand_equipped"] = null
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.OFFHAND:
			if equipped_items["offhand_equipped"] != null:
				equipped_items["offhand_equipped"].is_equipped = false
			equipped_items["offhand_equipped"] = item_inv_interact
			offhand_button.icon = item_inv_interact.item_inventory.item_icon
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
			jewelry_button.icon = item_inv_interact.item_inventory.item_icon
			item_inv_interact.is_equipped = true
			
	if transition_from_equip_screen:
		transition_from_equip_screen = false
		inventory_tabs.current_tab = 0

func _remove_item(item_inventory: item):
	for _item in inventory:
		if _item.get(item_inventory) != null:
			inventory.erase(_item)
			save_inventory()
			break
		break
	
func _drop_item(item_to_drop: item):
	var item_exists: bool = false
	var item_index: int
	
	for _item in inventory:
		if _item.get(item_to_drop) != null:
			item_exists = true
			item_index = inventory.find(_item)
			
	if !item_exists:
		return
	
	var inventory_stack_size: int = inventory[item_index][item_to_drop]
	if item_to_drop.is_stackable && inventory_stack_size > 0:
		drop_amount_pop_up.show_drop_popup()
		drop_amount_pop_up.update_slider_amounts(inventory_stack_size)
		if !drop_amount_pop_up.drop_amount.is_connected(popup_drop_item):
			drop_amount_pop_up.drop_amount.connect(popup_drop_item.bind(item_to_drop,item_index))
	elif !item_to_drop.is_stackable:
		var item_drop_add = load(item_to_drop.item_dropped_scene_path)
		var item_drop = item_drop_add.instantiate()
		item_drop.is_dropped = true
		get_tree().current_scene.add_child(item_drop)
		item_drop.global_position = Global.player.camera.global_position + (-Global.player.camera.global_transform.basis.z.normalized()*1.5)

func popup_drop_item(amount_to_drop: int, item_to_drop: item, item_index: int):
	var item_drop_add = load(item_to_drop.item_dropped_scene_path)
	inventory[item_index][item_to_drop] -= amount_to_drop
	var item_to_find = offhand.find_child(item_to_drop.item_name, false, false)
	if item_to_find:
		item_to_find.update_stack_size(-amount_to_drop)
	var item_drop = item_drop_add.instantiate()
	item_drop.is_dropped = true
	get_tree().current_scene.add_child(item_drop)
	item_drop.item_to_loot.pick_up_stack_size = amount_to_drop
	item_drop.global_position = Global.player.camera.global_position + (-Global.player.camera.global_transform.basis.z.normalized()*1.5)

func _update_display_text(_item: item):
	focused_item = _item
	item_name.text = focused_item.item_name
	item_description.text = focused_item.item_description
	item_type.text = ItemEquippableType.ITEM_EQUIPPABLE_TYPES.keys()[focused_item.item_type]
	item_icon.texture = focused_item.item_icon
	emit_signal("focused_item_changed", focused_item)


func _on_mainhand_button_pressed() -> void:
	inventory_tabs.current_tab = 1
	transition_from_equip_screen = true
	var item_list_count = item_list_tabs.get_tab_count()-1
	for i in item_list_count:
		if item_list_tabs.get_tab_title(i) == "Mainhand":
			item_list_tabs.current_tab = i

func _on_offhand_button_pressed() -> void:
	inventory_tabs.current_tab = 1
	transition_from_equip_screen = true
	var item_list_count = item_list_tabs.get_tab_count()-1
	for i in item_list_count:
		if item_list_tabs.get_tab_title(i) == "Offhand":
			item_list_tabs.current_tab = i

func _on_jewelry_button_pressed() -> void:
	inventory_tabs.current_tab = 1
	transition_from_equip_screen = true
	var item_list_count = item_list_tabs.get_tab_count()-1
	for i in item_list_count:
		if item_list_tabs.get_tab_title(i) == "Jewelry":
			item_list_tabs.current_tab = i


func _on_leg_button_pressed() -> void:
	inventory_tabs.current_tab = 1
	pass # Replace with function body.


func _on_chest_button_pressed() -> void:
	pass # Replace with function body.


func _on_ammo_button_pressed() -> void:
	transition_from_equip_screen = true
	var item_list_count = item_list_tabs.get_tab_count()-1
	for i in item_list_count:
		if item_list_tabs.get_tab_title(i) == "Consumables":
			item_list_tabs.current_tab = i


func _on_tab_bar_tab_changed(tab: int) -> void:
	if inventory_tabs.get_tab_title(tab) == "Equipment":
		equipment.visible = true
		inventory_list_container.visible = false
	if inventory_tabs.get_tab_title(tab) == "Inventory":
		equipment.visible = false
		inventory_list_container.visible = true

func reset_inventory(inventory_list: Array) -> void:
	for inventory_item: Dictionary in inventory_list:
		var _item = inventory_item.keys()[0]
		var stack_size = inventory_item.values()[0]
		_set_inventory_from_save_file(_item, stack_size)


func _set_inventory_from_save_file(item_signal: item, stack_size: int):
	var item_add = item_add_inventory.instantiate()
	item_add.connect("item_info", _update_display_text)
	item_add.connect("item_drop", _drop_item)
	item_add.connect("stack_size_changed", save_inventory)
	item_add.name = item_signal.item_name
	
	if !SignalBus.is_connected("player_stats_changed", item_signal.item_stats._update_player_stats):
		SignalBus.connect("player_stats_changed", item_signal.item_stats._update_player_stats)
	if !item_add.is_connected("equipped_signal",_update_equipped_items):
		item_add.connect("equipped_signal", _update_equipped_items)
	item_signal.item_stats._update_player_stats(Global.player.player_stats)
	
	match item_signal.item_type:
		
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.WEAPON:
			mainhand.add_child(item_add)
			item_add.item_inventory = item_signal
			item_add.item_stack_size = stack_size
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.OFFHAND:
			offhand.add_child(item_add)
			item_add.item_inventory = item_signal
			item_add.item_stack_size = stack_size
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.ARMOR:
			armor.add_child(item_add)
			item_add.item_inventory = item_signal
			item_add.item_stack_size = stack_size
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.JEWELRY:
			jewelry.add_child(item_add)
			item_add.item_inventory = item_signal
			item_add.item_stack_size = stack_size
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.CONSUMABLE:
			consumable.add_child(item_add)
			item_add.item_inventory = item_signal
			item_add.item_stack_size = stack_size
		ItemEquippableType.ITEM_EQUIPPABLE_TYPES.KEY:
			key.add_child(item_add)
			item_add.item_inventory = item_signal
			item_add.item_stack_size = stack_size
	var item_dict: Dictionary
	item_dict[item_signal] = stack_size
	inventory.append(item_dict)
