extends Node

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart


func _on_idle_state_entered() -> void:
	animation_tree.active = true
	animation_tree.set("parameters/conditions/idle", true)
	animation_tree.set("parameters/conditions/walk", false)
	source_npc.SPEED = 0
	state_chart.send_event("move")


func _on_idle_state_exited() -> void:
	pass # Replace with function body.


func _on_idle_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_approach_detector_rapid_approach_detected() -> void:
	source_npc.target = Global.player
	state_chart.send_event("howl")
