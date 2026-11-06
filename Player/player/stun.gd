extends Node

@export var state_chart: StateChart
@export var hands: Marker3D
@export var animation_tree: AnimationTree
@export var left_bone_attach: BoneAttachment3D
@export var right_bone_attach: BoneAttachment3D
@onready var stun_sfx: AudioStreamPlayer3D = $"../stunSFX"
@onready var stun_timer: Timer = $"../stunTimer"

func _on_stun_state_entered() -> void:
	#Global.player.can_move = false
	animation_tree.set("parameters/conditions/stagger", true)
	if left_bone_attach.get_child_count() > 0:
		left_bone_attach.get_child(0).deactivate()
	if right_bone_attach.get_child_count() > 0:
		right_bone_attach.get_child(0).activate(false)
	SignalBus.emit_signal("is_blocking", false)
	stun_sfx.pitch_scale = randf_range(0.8,1.2)
	stun_sfx.play()
	stun_timer.start()
	var _weapon
	
	if hands.offhand_weapon == null:
		_weapon = hands.bone_attachment.get_child(0)
		animation_tree.set("parameters/mainhandBlockBlendTree/Transition/transition_request", "stun")
	else:
		_weapon = hands.left_bone_attachment.get_child(0)
		animation_tree.set("parameters/offhandActivateBlendTree/Transition/transition_request", "stun")
	

func _on_stun_state_exited() -> void:
	GamePiecesEventBus.slow_player_requested(0)
	Global.player.can_move = true


func _on_stun_state_physics_processing(delta: float) -> void:
	GamePiecesEventBus.slow_player_requested(4)


func _on_stun_timer_timeout() -> void:
	animation_tree.set("parameters/conditions/stagger", false)
	state_chart.send_event("idle")
