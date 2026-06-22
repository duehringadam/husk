extends MenuButton

signal item_info(item_inv: item)
signal item_drop(item_inv: item)

@export var item_inventory: item: set = _update_item
@export var is_equipped: bool = false
@export var is_stackable: bool = false

@onready var stack_size: Label = $Label

func _ready() -> void:
	var popup: PopupMenu = get_popup()
	popup.id_pressed.connect(_item_menu_selected)

func _update_item(_item: item):
	item_inventory = _item
	if _item.is_stackable:
		_update_stack_size(0)
	_disable_options_on_item_type()

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

func _item_menu_selected(value: int):
	match value:
		0:
			if item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.CONSUMABLE:
				if item_inventory.is_stackable:
					_update_stack_size(-1)
					Global.player.consumable.consumable_item = item_inventory
		1:
			if item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.WEAPON:
				Global.player.mainhand.weapon = item_inventory
			elif item_inventory.item_type == ItemEquippableType.ITEM_EQUIPPABLE_TYPES.OFFHAND:
				Global.player.offhand.weapon = item_inventory
		2:
			pass
		3:
			if item_inventory.is_stackable:
				_update_stack_size(-1)
				item_drop.emit(item_inventory)
			else:
				item_drop.emit(item_inventory)
				SignalBus.emit_signal("remove_item", item_inventory)
		_:
			pass

func _update_stack_size(amount: int):
	item_inventory.current_stack_size = clampi(item_inventory.current_stack_size+amount, 0, item_inventory.max_stack_size)
	if item_inventory.current_stack_size > 0:
		self.disabled = false
	if item_inventory.current_stack_size <= 0:
		self.disabled = true
	
	stack_size.show()
	stack_size.text = str(item_inventory.current_stack_size)

func _on_mouse_entered() -> void:
	item_info.emit(item_inventory)
