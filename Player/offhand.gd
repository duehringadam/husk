extends Node3D

@export var weapon: item: set = _set_item
@onready var mainhand: Node3D = $"../mainhand"


func _set_item(new_item):
	weapon = new_item
	if mainhand.weapon != null:
		if mainhand.get_child(0).two_handed:
			return
	if get_child_count() != 0:
		unequip()
	var item_add = new_item.item_scene.instantiate()
	add_child(item_add)

func unequip():
	if get_child_count() != 0:
		get_child(0).queue_free()
