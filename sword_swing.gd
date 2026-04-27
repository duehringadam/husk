extends Node

@export var state_chart: StateChart
@export var bone_attach: BoneAttachment3D
@export var animation_tree: AnimationTree
@export var hand: Node3D
var weapon

func _ready() -> void:
	animation_tree["parameters/playback"].connect("state_finished", _anim_finished)

func _on_swing_left_state_entered() -> void:
	animation_tree.set("parameters/conditions/swing", true)
	for i in bone_attach.get_children():
		if i is Weapon:
			weapon = i
	if weapon:
		if weapon.swing_sound:
			weapon.swing_sound.pitch_scale = randf_range(0.9,1)
			weapon.swing_sound.play()
			weapon.trail.visible = true
	SignalBus.emit_signal("primary_active", true)
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov", Global.camera_fov,.25)
	get_tree().create_timer(1).timeout.connect(func(): state_chart.send_event("idle"))
	

func _on_swing_left_state_exited() -> void:
	GamePiecesEventBus.slow_player_requested(-2)
	SignalBus.emit_signal("primary_active", false)
	animation_tree.set("parameters/conditions/swing", false)
	if weapon:
		weapon.trail.visible = false


func _on_swing_left_state_processing(delta: float) -> void:
	pass

func _anim_finished(state: StringName):
	if state == "swing_right":
		state_chart.send_event("idle")
	if state == "swing_left":
		state_chart.send_event("idle")
	if state == "swing_forward":
		state_chart.send_event("idle")
	if state == "swing_back":
		state_chart.send_event("idle")
	
