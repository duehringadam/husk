extends Node3D

@export var ray: RayCast3D
@export var weapon: item: set = _set_item

@onready var offhand: Node3D = $"../offhand"


func _set_item(new_item):
	weapon = new_item
	var item_add = new_item.item_scene.instantiate()
	if item_add.two_handed:
		offhand.unequip()
	if get_child_count() != 0:
		unequip()
	add_child(item_add)
	item_add.player_lookat_ray = ray

func unequip():
	get_child(0).queue_free()
