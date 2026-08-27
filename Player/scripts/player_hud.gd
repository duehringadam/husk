extends Control

@onready var inventory: PanelContainer = %inventory
@onready var selection_wheel: Control = %SelectionWheel
@onready var selection_wheel_darken: ColorRect = $selectionWheelDarken

var inventory_open: bool = false
var consumable_open: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		inventory_menu()
	if event.is_action_pressed("consumable"):
		consumable_menu()
	if event.is_action_released("consumable"):
		consumable_menu()
		
func inventory_menu():
	if inventory_open:
		inventory.close_inventory()
	else:
		inventory.open_inventory()

	inventory_open = !inventory_open

func consumable_menu():
	if consumable_open:
		selection_wheel_darken.hide()
		selection_wheel.close()
	else:
		selection_wheel_darken.show()
		selection_wheel.open()
	consumable_open = !consumable_open
