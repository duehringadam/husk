extends Node

@export var hands: Marker3D
@export var animation_tree: AnimationTree

@onready var stun_sfx: AudioStreamPlayer3D = $"../stunSFX"

func _on_stun_state_entered() -> void:
	GamePiecesEventBus.slow_player_requested(-2)
	stun_sfx.pitch_scale = randf_range(0.8,1.2)
	stun_sfx.play()
	
	var _weapon
	
	if hands.offhand_weapon == null:
		_weapon = hands.bone_attachment.get_child(0)
		animation_tree.set("parameters/mainhandBlockBlendTree/Transition/transition_request", "stun")
	else:
		_weapon = hands.left_bone_attachment.get_child(0)
		animation_tree.set("parameters/offhandActivateBlendTree/Transition/transition_request", "stun")
	

func _on_stun_state_exited() -> void:
	pass # Replace with function body.


func _on_stun_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
