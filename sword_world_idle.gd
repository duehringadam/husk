extends Node

@export var weapon: Node3D
@onready var state_chart: StateChart = $"../../.."
@onready var damage_component: DamageComponent = $"../../../../MeshInstance3D/DamageComponent"

func _on_idle_state_entered() -> void:
	SignalBus.emit_signal("can_attack", true)
	state_chart.set_expression_property("can_attack", true)
	damage_component.monitorable = false
	damage_component.monitoring = false


func _on_idle_state_exited() -> void:
	SignalBus.emit_signal("can_attack", false)
	state_chart.set_expression_property("can_attack", false)



func _on_idle_state_processing(delta: float) -> void:
	pass # Replace with function body.
