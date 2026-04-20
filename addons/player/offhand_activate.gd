extends Node

@export var left_hand: Marker3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree

func _on_activate_state_entered() -> void:
	animation_tree.set("parameters/conditions/activate", true)


func _on_activate_state_exited() -> void:
	left_hand.bone_attachment.get_child(0).deactivate()


func _on_activate_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_activate_state_input(event: InputEvent) -> void:
	if event.is_action_released("attack_secondary"):
		animation_tree.set("parameters/conditions/activate", false)
		state_chart.send_event("idle")
