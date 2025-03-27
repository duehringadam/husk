extends Node

@export var weapon: Node3D
@onready var state_chart: StateChart = $"../../.."


func _on_idle_state_entered() -> void:
	SignalBus.emit_signal("can_attack", true)
	SignalBus.emit_signal("primary_active",false)
	state_chart.set_expression_property("can_attack", true)



func _on_idle_state_exited() -> void:
	SignalBus.emit_signal("can_attack", false)
	SignalBus.emit_signal("primary_active",true)
	state_chart.set_expression_property("can_attack", false)



func _on_idle_state_processing(delta: float) -> void:
	pass # Replace with function body.
