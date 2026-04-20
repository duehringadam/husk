extends Node

@export var left_hand: Marker3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree
@export var bone_attach: BoneAttachment3D

func _on_idle_state_entered() -> void:
	animation_tree.set("parameters/conditions/idle", true)


func _on_idle_state_exited() -> void:
	pass


func _on_idle_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_idle_state_input(event: InputEvent) -> void:
	if bone_attach.get_child_count() > 0:
		if event.is_action_pressed("attack_secondary") && left_hand.can_activate:
			animation_tree.set("parameters/conditions/idle", false)
			state_chart.send_event("activate")
