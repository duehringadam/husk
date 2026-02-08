extends Node

@export var source_npc: CharacterBody3D
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

func _on_taunt_state_entered() -> void:
	source_npc.SPEED = 0
	AudioManager.play_sound(load("res://sfx/zombie-death-2-95167.mp3"), source_npc.global_position,-1)
	animation_tree.set("parameters/conditions/aggro", true)
	await get_tree().create_timer(1).timeout
	animation_tree.set("parameters/conditions/aggro", false)
	state_chart.send_event("move")


func _on_taunt_state_exited() -> void:
	pass # Replace with function body.


func _on_taunt_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
