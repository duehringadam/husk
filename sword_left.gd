extends Node

@export var state_chart: StateChart
@export var animation_tree: AnimationTree
@export var right_hand: Marker3D

func _on_left_state_entered() -> void:
	animation_tree.set("parameters/conditions/hold_left", true)


func _on_left_state_exited() -> void:
	animation_tree.set("parameters/conditions/hold_left", false)


func _on_left_state_processing(delta: float) -> void:
	Global.player.stamina_component.modify_stamina(-right_hand.weapon.stamina_cost*delta)
	if Global.player.stamina_component.current_stamina <=0: state_chart.send_event("swing")
	if not (Input.is_action_pressed("attack_primary")):
		state_chart.send_event("swing")
