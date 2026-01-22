extends Node

@export var source_npc: CharacterBody3D
@export var animation_tree: AnimationTree
@export var state_chart: StateChart
@export var distance: float


func _on_knocked_back_state_entered() -> void:
	animation_tree.set("parameters/conditions/stagger", true)
	
	var kb_source = state_chart.get_expression_property("knockback_source")
	var kb :Vector3 = kb_source.global_position - source_npc.global_position
	var kb_dir = kb.normalized()
	kb_dir.y = 0
	var kb_amount = kb_dir * distance
	source_npc.velocity = -kb_amount
	await get_tree().create_timer(.5).timeout
	animation_tree.set("parameters/conditions/stagger", false)
	state_chart.send_event("idle")


func _on_knocked_back_state_exited() -> void:
	pass # Replace with function body.


func _on_knocked_back_state_physics_processing(delta: float) -> void:
	pass
