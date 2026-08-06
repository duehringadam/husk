extends Node

@export var state_chart: StateChart
@export var bone_attach: BoneAttachment3D
@export var animation_tree: AnimationTree

var weapon

func _on_block_hit_state_entered() -> void:
	for i in bone_attach.get_children():
		if i is Weapon:
			weapon = i
	animation_tree.set("parameters/conditions/block_hit", true)
	weapon.swing_sound.pitch_scale = randf_range(0.8,1.2)
	weapon.swing_sound.play()


func _on_block_hit_state_exited() -> void:
	animation_tree.set("parameters/conditions/block_hit", false)


func _on_block_hit_state_processing(delta: float) -> void:
	pass # Replace with function body.
