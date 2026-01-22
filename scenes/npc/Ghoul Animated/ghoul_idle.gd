extends Node

@export var source_npc: CharacterBody3D
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

func _on_idle_state_entered() -> void:
	animation_tree.set("parameters/conditions/idle", true)
	animation_tree.set("parameters/conditions/walk", false)
	source_npc.SPEED = 0


func _on_idle_state_exited() -> void:
	pass # Replace with function body.


func _on_idle_state_physics_processing(delta: float) -> void:
	pass
