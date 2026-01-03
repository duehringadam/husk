extends Node3D

@export var weapon: item: set = _set_item
@export var offhand: Node3D


func _set_item(new_item):
	if new_item != null:
		weapon = new_item
		print(weapon)
		var item_add = new_item.item_scene.instantiate()
		if is_instance_valid(offhand):
			if item_add.two_handed and offhand.get_child_count() != 0:
				offhand.unequip()
		if get_child_count() != 0:
			unequip()
		add_child(item_add)

func unequip():
	weapon = null
	for i in get_children():
		i.queue_free()
