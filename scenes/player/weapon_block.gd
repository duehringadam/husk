extends Node

@export var state_chart: StateChart
@export var weapon: Node3D
@export var swing_audio: AudioStreamPlayer3D
@export var trail: GPUTrail3D
@onready var animation_tree: AnimationTree = $"../../../../AnimationTree"

func _on_block_state_entered() -> void:
	SignalBus.emit_signal("primary_active", true)
	GamePiecesEventBus.slow_player_requested(2)
	SignalBus.emit_signal("is_blocking",true)
	animation_tree.set("parameters/conditions/block", true)
	animation_tree.set("parameters/conditions/unblock", false)


func _on_block_state_exited() -> void:
	GamePiecesEventBus.slow_player_requested(-2)


func _on_block_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_block_state_input(event: InputEvent) -> void:
	if event.is_action_released("attack_secondary"):
		SignalBus.emit_signal("is_blocking",false)
		animation_tree.set("parameters/conditions/block", false)
		animation_tree.set("parameters/conditions/unblock", true)
		state_chart.send_event("idle")
		
