extends Node

@export var left_hand: Marker3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree

func _on_activate_state_entered() -> void:
	animation_tree.set("parameters/conditions/activate", true)
	if left_hand.weapon.mana_cost > 0:
		Global.player.mana_component.modify_mana(-left_hand.weapon.mana_cost)
	if left_hand.weapon.stamina_cost > 0:
		Global.player.stamina_component.modify_stamina(-left_hand.weapon.stamina_cost)

func _on_activate_state_exited() -> void:
	left_hand.bone_attachment.get_child(0).deactivate()


func _on_activate_state_physics_processing(delta: float) -> void:
	if left_hand.weapon.stamina_cost > 0:
		Global.player.stamina_component.modify_stamina(-left_hand.weapon.stamina_cost*delta)
	if left_hand.weapon.constant_mana_drain:
		Global.player.mana_component.modify_mana(-left_hand.weapon.mana_cost * delta)
		if Global.player.mana_component.current_mana <= 0:
			left_hand.bone_attachment.get_child(0).deactivate()
			state_chart.send_event("cant_use")


func _on_activate_state_input(event: InputEvent) -> void:
	if event.is_action_released("attack_secondary"):
		animation_tree.set("parameters/conditions/activate", false)
		state_chart.send_event("idle")
