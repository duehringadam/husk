extends Node
@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"


func _on_idle_state_entered() -> void:
	SignalBus.emit_signal("secondary_active", false)
	SignalBus.emit_signal("is_blocking",false)


func _on_idle_state_exited() -> void:
	pass # Replace with function body.


func _on_idle_state_processing(delta: float) -> void:
	pass # Replace with function body.
