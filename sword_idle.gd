extends Node

@export var weapon: Node3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree
@export var trail: GPUTrail3D

func _on_idle_state_entered() -> void:
	trail.visible = false
	weapon.can_attack = true
	animation_tree.set("parameters/conditions/idle", true)
	weapon.damage_component.hits.clear()
	SignalBus.emit_signal("primary_active", false)


func _on_idle_state_exited() -> void:
	weapon.can_attack = false
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov",Global.camera_fov+10,.25)
	animation_tree.set("parameters/conditions/idle", false)


func _on_idle_state_processing(delta: float) -> void:

	if Input.is_action_pressed("attack_primary") && weapon.can_attack:
		if weapon.attack_dir.y < -.9:
			state_chart.send_event("hold_forward")
			
		elif weapon.attack_dir.y > .9:
			state_chart.send_event("hold_back")
			
		elif weapon.attack_dir.x < -0.9:
			state_chart.send_event("hold_right")
			
		elif weapon.attack_dir.x > 0.9:
			state_chart.send_event("hold_left")
			
		else:
			state_chart.send_event("hold_right")
			
	if Input.is_action_just_pressed("attack_secondary"):
		if weapon.two_handed:
			state_chart.send_event("block")
		
