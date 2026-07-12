extends Node

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

func _on_lunging_state_entered() -> void:
	animation_tree.set("parameters/conditions/lunge", true)
	source_npc.SPEED = 0
	state_chart.send_event("patrol")


func _on_lunging_state_exited() -> void:
	pass # Replace with function body.
