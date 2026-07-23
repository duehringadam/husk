extends Node

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart
@export var vision_area: Area3D

func _ready() -> void:
	if !vision_area.is_connected("max_aggro", _on_vision_area_max_aggro):
		vision_area.connect("max_aggro", _on_vision_area_max_aggro)
		
func _on_idle_state_entered() -> void:
	animation_tree.set("parameters/conditions/idle", true)
	animation_tree.set("parameters/conditions/walk", false)
	source_npc.SPEED = 0
	state_chart.send_event("patrol")


func _on_idle_state_exited() -> void:
	pass # Replace with function body.


func _on_idle_state_physics_processing(delta: float) -> void:
	if source_npc.target != null:
		state_chart.send_event("chase")


func _on_vision_area_max_aggro(aggro_amount: float, aggro_position: Node3D) -> void:
	if aggro_amount >= 1.0:
		source_npc.target = aggro_position
		state_chart.send_event("chase")


func _on_approach_detector_rapid_approach_detected() -> void:
	state_chart.send_event("chase")
