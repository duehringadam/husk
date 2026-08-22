class_name item_inventory_interact
extends MenuButton

signal item_info(item_inv: item)
signal item_drop(item_inv: item)
signal equipped_signal(item_to_equip: item_inventory_interact)
signal stack_size_changed

@export var item_inventory: item: set = _update_item
@export var item_stack_size: int: set = _set_stack_size
@export var is_equipped: bool = false: set = _update_is_equipped

@onready var stack_size: Label = $Label
@onready var equipped: TextureRect = $equipped
@onready var popup: PopupMenu = get_popup()

func _ready() -> void:
	popup.id_pressed.connect(_item_menu_selected)

func _update_item(_item: item):
	_item.update_stack_size.connect(update_stack_size)
	_item.set_stack_size.connect(_set_stack_size)
	item_inventory = _item
	if _item.item_icon:
		icon = _item.item_icon
	if _item.is_stackable:
		update_stack_size(1)
	_disable_options_on_item_type()


func _update_is_equipped(value: bool):
	is_equipped = value
	equipped.visible = value
	
func _disable_options_on_item_type():
		match item_inventory.item_type:
			ItemEquippableType.ITEM_EQUIPPABLE_TYPES.WEAPON:
				self["popup/item_0/disabled"] = true
			ItemEquippableType.ITEM_EQUIPPABLE_TYPES.OFFHAND:
				self["popup/item_0/disabled"] = true
			ItemEquippableType.ITEM_EQUIPPABLE_TYPES.ARMOR:
				self["popup/item_0/disabled"] = true
			ItemEquippableType.ITEM_EQUIPPABLE_TYPES.JEWELRY:
				self["popup/item_0/disabled"] = true
			ItemEquippableType.ITEM_EQUIPPABLE_TYPES.CONSUMABLE:
				self["popup/item_1/disabled"] = true
				self["popup/item_2/disabled"] = true
			ItemEquippableType.ITEM_EQUIPPABLE_TYPES.KEY:
				self["popup/item_3/disabled"] = true
		if !item_inventory.can_be_dropped:
			self["popup/item_3/disabled"] = true

func _item_menu_selected(value: int):
	match value:
		0:
			if item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.CONSUMABLE:
				if item_inventory.is_stackable:
					item_inventory._update_stack_size(-1)
					Global.player.consumable.consumable_item = item_inventory
		1:
			if !self.is_equipped:
				self.is_equipped = true
				equipped_signal.emit(self)
				if item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.WEAPON:
					Global.player.mainhand.weapon = item_inventory
				elif item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.OFFHAND:
					Global.player.offhand.weapon = item_inventory
				elif item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.ARMOR:
					pass
				elif item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.JEWELRY:
					pass
		2:
			if self.is_equipped:
				self.is_equipped = false
				if item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.WEAPON:
					Global.player.mainhand.unequip()
					Global.player.mainhand.disable()
				elif item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.OFFHAND:
					Global.player.offhand.unequip()
					Global.player.offhand.disable()
				elif item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.ARMOR:
					pass
				elif item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.JEWELRY:
					pass
				Global.player.inventory.unequip(item_inventory.item_type)
		3:
			if self.is_equipped:
				self.is_equipped = false
				if item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.WEAPON:
					Global.player.mainhand.unequip()
					Global.player.mainhand.disable()
				if item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.OFFHAND:
					Global.player.offhand.unequip()
					Global.player.offhand.disable()
			
			if item_inventory.is_stackable:
				item_drop.emit(item_inventory)
			else:
				item_drop.emit(item_inventory)
				SignalBus.emit_signal("remove_item", item_inventory)
				queue_free()
		_:
			pass

func _set_stack_size(amount: int):
	item_stack_size = amount
	if item_inventory.is_stackable:
		if item_stack_size > 0:
			self.disabled = false
		if item_stack_size <= 0:
			self.disabled = true
		if item_stack_size <= 0 && is_equipped:
			self.disabled = true
			self.is_equipped = false
			Global.player.offhand.unequip()
			Global.player.offhand.disable()
		stack_size.show()
		stack_size.text = str(item_stack_size)
	if item_stack_size <= 0 && is_equipped:
		Global.player.offhand.unequip()
		Global.player.offhand.disable()
	stack_size_changed.emit()

func update_stack_size(amount: int):
	item_stack_size += amount
	if item_inventory.is_stackable:
		if item_stack_size > 0:
			self.disabled = false
		if item_stack_size <= 0:
			self.disabled = true
		if item_stack_size <= 0 && is_equipped:
			self.disabled = true
			self.is_equipped = false
			Global.player.offhand.unequip()
			Global.player.offhand.disable()
		stack_size.show()
		stack_size.text = str(item_stack_size)
	if item_stack_size <= 0 && is_equipped:
		Global.player.offhand.unequip()
		Global.player.offhand.disable()
	stack_size_changed.emit()

func _on_mouse_entered() -> void:
	item_info.emit(item_inventory)
