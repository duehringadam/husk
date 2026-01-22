extends Node

@export var weapon: Weapon
@export var state_chart: StateChart

func _on_idle_state_entered() -> void:
	pass # Replace with function body.


func _on_idle_state_exited() -> void:
	pass # Replace with function body.


func _on_idle_state_processing(delta: float) -> void:
	if Input.is_action_pressed("attack_primary") && weapon.can_attack:
		state_chart.send_event("shoot")
	if Input.is_action_just_pressed("attack_secondary"):
		if weapon.two_handed:
			state_chart.send_event("block")
