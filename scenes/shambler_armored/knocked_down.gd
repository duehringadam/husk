extends Node

@export var source_npc: npc
@export var state_chart: StateChart

func _on_knocked_down_state_entered() -> void:
	source_npc.fall()

func _on_knocked_down_state_exited() -> void:
	pass # Replace with function body.

func _on_knocked_down_state_physics_processing(delta: float) -> void:
	pass
