extends Node

@export var weapon: Node3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree

func _on_idle_state_entered() -> void:
	SignalBus.emit_signal("primary_active", false)
	weapon.can_attack = true


func _on_idle_state_exited() -> void:
	weapon.can_attack = false
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov",Global.camera_fov+10,.25)
	


func _on_idle_state_processing(delta: float) -> void:
	if weapon.bone_attachment.get_child_count() > 0:
		if Input.is_action_just_pressed("attack_primary") && weapon.can_attack && Global.player.can_attack:
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
			if weapon.weapon:
				if weapon.weapon.two_handed:
					state_chart.send_event("block")
		
