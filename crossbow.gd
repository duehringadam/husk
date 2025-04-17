extends Weapon

func _ready() -> void:
	state_chart.set_expression_property("can_attack", true)
	SignalBus.connect("secondary_active", secondary_active)

func secondary_active(value:bool):
	secondary_active_bool = value
	

func _on_damage_component_body_entered(body: Node3D) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_primary"):
		state_chart.send_event("shoot")

func _on_damage_component_area_entered(area: Area3D) -> void:
	pass
