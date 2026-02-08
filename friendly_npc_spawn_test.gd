extends StaticBody3D

@export var npc_to_spawn: PackedScene
@export var spawn_location_node: Node3D
@export var bounding_box: bounding_box_component
var npc_to_add

func _ready() -> void:
	npc_to_add = npc_to_spawn.instantiate()

func _on_spawn_on_complete(controller: InteractionController) -> void:
	var npc_add = npc_to_add.duplicate()
	get_tree().current_scene.add_child(npc_add)
	npc_add.global_position = spawn_location_node.global_position
	
