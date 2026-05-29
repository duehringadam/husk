extends Node

@export var weapon: Node3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree
@export var bone_attach: BoneAttachment3D

func _on_idle_state_entered() -> void:
	if bone_attach.get_child_count() > 0:
		SignalBus.emit_signal("primary_active", false)
	weapon.can_attack = true


func _on_idle_state_exited() -> void:
	if bone_attach.get_child_count() > 0:
		SignalBus.emit_signal("primary_active", true)
	weapon.can_attack = false
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov",Global.camera_fov+10,.25)


func _on_idle_state_processing(delta: float) -> void:
	if weapon.bone_attachment.get_child_count() > 0:
		if Input.is_action_just_pressed("attack_primary") && weapon.can_attack && Global.player.can_attack:
			
			if weapon.attack_dir.y < -.5:
				state_chart.send_event("hold_forward")
				
			elif weapon.attack_dir.y > .5:
				state_chart.send_event("hold_back")
				
			elif weapon.attack_dir.x < -0.5:
				state_chart.send_event("hold_right")
				
			elif weapon.attack_dir.x > 0.5:
				state_chart.send_event("hold_left")
				
			else:
				state_chart.send_event("hold_right")
				
		if Input.is_action_just_pressed("attack_secondary") && weapon.can_attack:
			if weapon.weapon:
				if weapon.weapon.two_handed:
					state_chart.send_event("block")
		
