extends Node

@export var spell: Node3D
@export var state_chart: StateChart
@export var spell_telekinesis: Node3D

func _on_missed_state_entered() -> void:
	spell.deactivate()
	SignalBus.emit_signal("telekinesis_fail")
	spell_telekinesis.grabbed_object= null
	state_chart.send_event("idle")


func _on_missed_state_exited() -> void:
	pass # Replace with function body.


func _on_missed_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
