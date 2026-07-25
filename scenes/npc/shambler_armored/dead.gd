extends Node

@export var source_npc: CharacterBody3D
@export var animation_tree: AnimationTree
@export var physical_bone_sim: PhysicalBoneSimulator3D

func _on_dead_state_entered() -> void:
	physical_bone_sim.influence = 1.0
	physical_bone_sim.active = true
	animation_tree.active = false
