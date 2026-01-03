extends StaticBody3D

@export var npc_to_spawn: PackedScene
@export var spawn_location_node: Node3D

func _on_spawn_on_complete(controller: InteractionController) -> void:
	var npc_to_spawn_add = npc_to_spawn.instantiate()
	get_tree().current_scene.add_child(npc_to_spawn_add)
	npc_to_spawn_add.global_position = spawn_location_node.global_position
