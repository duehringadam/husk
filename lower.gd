extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"

func _on_lower_state_entered() -> void:
	#animation_player.play("lower")
	SignalBus.emit_signal("secondary_active", false)
	SignalBus.emit_signal("is_blocking",false)


func _on_lower_state_exited() -> void:
	pass


func _on_lower_state_processing(delta: float) -> void:
	pass # Replace with function body.
