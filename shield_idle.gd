extends Node
@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"


func _on_idle_state_entered() -> void:
	GamePiecesEventBus.slow_player_requested(-1.5)
	SignalBus.emit_signal("secondary_active", false)
	SignalBus.emit_signal("is_blocking",false)


func _on_idle_state_exited() -> void:
	GamePiecesEventBus.slow_player_requested(1.5)


func _on_idle_state_processing(delta: float) -> void:
	pass # Replace with function body.
