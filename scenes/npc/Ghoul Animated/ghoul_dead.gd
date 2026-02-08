extends Node

@export var source_npc: CharacterBody3D
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

func _on_dead_state_entered() -> void:
	source_npc.ghoul_parent.top_level = true
	source_npc.collision_layer = 0
	source_npc.SPEED = 0
	animation_tree.active = false
	await get_tree().create_timer(60).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(source_npc.mesh, "transparency",1.0,1)
	await tween.finished
	source_npc.queue_free()


func _on_dead_state_exited() -> void:
	pass # Replace with function body.


func _on_dead_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
