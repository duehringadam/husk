extends Node

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

func _on_dead_state_entered() -> void:
	source_npc.fall()
	animation_tree.active = false


func _on_dead_state_exited() -> void:
	pass # Replace with function body.


func _on_dead_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
