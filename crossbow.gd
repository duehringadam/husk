extends Weapon


func _ready() -> void:
	state_chart.set_expression_property("can_attack", true)
	SignalBus.connect("secondary_active", secondary_active)

func secondary_active(value:bool):
	secondary_active_bool = value
	

func _on_damage_component_body_entered(body: Node3D) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			state_chart.send_event("shoot")

func _on_damage_component_area_entered(area: Area3D) -> void:
	pass
