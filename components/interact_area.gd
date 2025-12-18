extends Area3D

signal player_close(value: bool)

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		emit_signal("player_close", false)
		SignalBus.interact_close.emit()

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		emit_signal("player_close", true)
