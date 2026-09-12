extends Node

@export var state_chart: StateChart
@export var bone_attach: BoneAttachment3D
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var hand: Node3D

var weapon

func _on_swing_3_state_entered() -> void:
	Global.player.stamina_component.modify_stamina(-40)
	var state_machine_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
	state_machine_playback.travel("attack_3")
	for i in bone_attach.get_children():
		if i is Weapon:
			weapon = i
	if weapon:
		if weapon.swing_sound:
			weapon.swing_sound.pitch_scale = randf_range(0.9,1.1)
			weapon.swing_sound.play()
	SignalBus.emit_signal("primary_active", true)
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov", Global.camera_fov,.25)


func _on_swing_3_state_exited() -> void:
	pass # Replace with function body.


func _on_swing_3_state_input(event: InputEvent) -> void:
	pass # Replace with function body.


func _on_swing_3_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_end_timer_timeout() -> void:
	state_chart.send_event("idle")
