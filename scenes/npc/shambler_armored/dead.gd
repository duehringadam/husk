extends Node

@export var source_npc: CharacterBody3D
@export var animation_tree: AnimationTree


func _on_dead_state_entered() -> void:
	source_npc.fall()
	animation_tree.active = false
