extends Node

@export var weapon: Node3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree

func _on_idle_state_entered() -> void:
	animation_tree.set("parameters/conditions/idle", true)
	weapon.damage_component.hits.clear()


func _on_idle_state_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov",Global.camera_fov+10,.25)
	animation_tree.set("parameters/conditions/idle", false)


func _on_idle_state_processing(delta: float) -> void:
	if Input.is_action_pressed("attack_primary"):
		if Global.player.input_dir.x < 0 && Global.player.input_dir.z == 0:
			state_chart.send_event("hold_left")
			
		elif Global.player.input_dir.x > 0 && Global.player.input_dir.z == 0:
			state_chart.send_event("hold_right")
			
		if Global.player.input_dir.z < 0:
			state_chart.send_event("hold_forward")
			
		elif Global.player.input_dir.z > 0:
			state_chart.send_event("hold_back")
			
		elif Global.player.input_dir.x == 0 && Global.player.input_dir.z == 0:
			state_chart.send_event("hold_right")
	if Input.is_action_pressed("attack_secondary"):
		if weapon.two_handed:
			state_chart.send_event("block")
