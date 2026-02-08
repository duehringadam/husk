extends Node

@export var source_npc: CharacterBody3D
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

func _on_swing_state_entered() -> void:
	source_npc.SPEED = 0
	animation_tree.set("parameters/conditions/walk", false)
	if source_npc.left_arm && source_npc.right_arm:
		var rand = randf()
		if rand > 0.5:
			animation_tree.set("parameters/conditions/chargeLeft", true)
		else:
			animation_tree.set("parameters/conditions/chargeRight", true)
			
	if source_npc.right_arm && !source_npc.left_arm:
		animation_tree.set("parameters/conditions/chargeRight", true)
	if !source_npc.right_arm && source_npc.left_arm:
		animation_tree.set("parameters/conditions/chargeLeft", true)
	
			
	await get_tree().create_timer(1).timeout
	animation_tree.set("parameters/conditions/chargeLeft", false)
	animation_tree.set("parameters/conditions/chargeRight", false)
	state_chart.send_event("move")

func _on_swing_state_exited() -> void:
	pass


func _on_swing_state_physics_processing(delta: float) -> void:
	pass
