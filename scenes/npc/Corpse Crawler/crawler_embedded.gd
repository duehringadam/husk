extends Node

@export var hurtbox: hurtbox_component

func _on_embedded_state_entered() -> void:
	hurtbox.monitorable = false
	hurtbox.monitoring = false


func _on_embedded_state_exited() -> void:
	hurtbox.monitorable = true
	hurtbox.monitoring = true


func _on_embedded_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
