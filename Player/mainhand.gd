extends Node3D

@export var ray: RayCast3D
@export var weapon: item: set = _set_item


func _set_item(new_item):
	if get_child_count() != 0:
		get_child(0).queue_free()
	var item_add = new_item.item_scene.instantiate()
	add_child(item_add)
	item_add.player_lookat_ray = ray
