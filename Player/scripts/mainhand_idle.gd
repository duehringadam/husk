extends Node

@export var weapon: Node3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree
@export var bone_attach: BoneAttachment3D

var current_node: StringName
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
	var state_machine_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
	current_node = state_machine_playback.get_current_node()
	
func _on_idle_state_unhandled_input(event: InputEvent) -> void:
	
	if !current_node.contains("idle"): 
		return
	
	if weapon.bone_attachment.get_child_count() > 0:
			if Global.player.stamina_component.current_stamina < weapon.weapon.stamina_cost:
				return
			if event.is_action_pressed("attack_primary") && weapon.can_attack && Global.player.can_attack:
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
					
			if event.is_action_pressed("attack_secondary") && Global.player.can_attack && weapon.can_attack:
				if weapon.weapon:
					if weapon.weapon.two_handed:
						state_chart.send_event("block")
					elif !weapon.weapon.two_handed and weapon.offhand.weapon == null:
						state_chart.send_event("block")
