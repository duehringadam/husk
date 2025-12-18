extends Node

@export var state_chart: StateChart
@onready var mainhand_anim: AnimationPlayer = $"../../../../Mainhand_Anim"


func _on_held_back_state_entered() -> void:
	mainhand_anim.play("one_handed_sword_hold_back")
	SignalBus.emit_signal("can_attack", false)
	SignalBus.emit_signal("primary_active",true)


func _on_held_back_state_exited() -> void:
	pass # Replace with function body.


func _on_held_back_state_processing(delta: float) -> void:
	if not (Input.is_action_pressed("attack_primary")) and !mainhand_anim.is_playing():
		state_chart.send_event("attack_back")
