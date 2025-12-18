extends PanelContainer

@onready var inventory_container: VBoxContainer = $PanelContainer/ScrollContainer/VBoxContainer
var item_add_inventory = preload("res://item_inventory.tscn")

func _ready() -> void:
	SignalBus.item_interact.connect(_update_inventory)

func open_inventory():
	GamePiecesEventBus.emit_signal("camera_lock_requested", true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	visible = true

func close_inventory():
	GamePiecesEventBus.emit_signal("camera_lock_requested", false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	visible = false


func _update_inventory(item_signal: item):
		var item_add = item_add_inventory.instantiate()
		inventory_container.add_child(item_add)
		item_add.item_inventory = item_signal
		item_add.item_name.text = item_signal.item_name
		item_add.description.text = item_signal.item_description
