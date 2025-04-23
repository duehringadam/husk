extends Node

@export var weapon: Node3D
@onready var state_chart: StateChart = $"../../.."
@onready var gpu_trail: GPUTrail3D = $"../../../../MeshInstance3D/GPUTrail3D"



func _on_idle_state_entered() -> void:
	weapon.damage_component.hits.clear()
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov", Global.camera_fov,.25)
	state_chart.set_expression_property("can_attack", true)
	gpu_trail.visible = false
	SignalBus.emit_signal("can_attack", true)
	SignalBus.emit_signal("primary_active",false)
	



func _on_idle_state_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov",Global.camera_fov+10,.25)
	state_chart.set_expression_property("can_attack", false)
	SignalBus.emit_signal("can_attack", false)
	SignalBus.emit_signal("primary_active",true)


func _on_idle_state_processing(delta: float) -> void:
	pass # Replace with function body.
