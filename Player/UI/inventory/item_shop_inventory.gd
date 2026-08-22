extends item_inventory_interact

@onready var cost: Label = $cost

func _update_item(_item: item):
	item_inventory = _item
	if _item.item_icon:
		icon = _item.item_icon
	if _item.is_stackable:
		update_stack_size(0)
	if _item.item_cost > 0:
		cost.text = str(_item.item_cost)

func _item_menu_selected(value: int):
	match value:
		0:
			if Global.player.player_currency.player_currency >= item_inventory.item_cost:
				SignalBus.emit_signal("enemy_currency_dropped", -item_inventory.item_cost)
				update_stack_size(-1)
		_:
			pass

func _on_mouse_entered() -> void:
	item_info.emit(item_inventory)

func update_stack_size(amount: int):
	item_stack_size = clampi(item_stack_size+amount,0,item_inventory.max_stack_size)
	if item_stack_size > 0:
		self.disabled = false
	if item_stack_size <= 0:
		self.disabled = true
	stack_size.show()
	stack_size.text = str(item_stack_size)
	stack_size_changed.emit()
