extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var state_chart: StateChart = $"../../.."
@onready var damage_component: DamageComponent = $"../../../../MeshInstance3D/DamageComponent"

func _on_back_state_entered() -> void:
	damage_component.monitorable = true
	damage_component.monitoring = true
	animation_player.play("swing_back")
	await animation_player.animation_finished
	state_chart.send_event("idle")



func _on_back_state_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_back_state_exited() -> void:
	pass # Replace with function body.
