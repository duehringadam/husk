extends Node

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart
@export var death_sound: AudioStreamPlayer3D
@export var damage_components_to_disable: Array[DamageComponent]
func _on_dead_state_entered() -> void:
	source_npc.fall()
	animation_tree.active = false
	source_npc.collision_layer = 0
	death_sound.pitch_scale = randf_range(.8,1.2)
	death_sound.play()
	for i in damage_components_to_disable:
		i.monitorable = false
		i.monitoring = false
	


func _on_dead_state_exited() -> void:
	pass # Replace with function body.


func _on_dead_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
