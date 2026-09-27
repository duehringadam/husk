extends Node

@export var state_chart: StateChart
@export var bone_attach: BoneAttachment3D
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var hand: Node3D

@onready var input_buffer: Timer = $"../inputBuffer"
@onready var end_timer: Timer = $"../endTimer"


var weapon
var attack_pressed: bool = false
var check_buffer: bool = false
var block_pressed: bool = false

func _on_swing_state_entered() -> void:
	var state_machine_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
	input_buffer.start()
	end_timer.start()
	check_buffer = false
	attack_pressed = false
	Global.player.stamina_component.modify_stamina(-40)
	state_machine_playback.travel("attack")
	for i in bone_attach.get_children():
		if i is Weapon:
			weapon = i
	if weapon:
		if weapon.swing_sound:
			weapon.swing_sound.pitch_scale = randf_range(0.9,1.1)
			weapon.swing_sound.play()
			
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov", Global.camera_fov,.25)


func _on_swing_state_exited() -> void:
	check_buffer = false
	block_pressed = false
	attack_pressed = false
	input_buffer.stop()
	end_timer.stop()


func _on_swing_state_physics_processing(delta: float) -> void:
	var state_machine_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
	var current_node: StringName = state_machine_playback.get_current_node()
	var animation_state_tree_root: AnimationNodeStateMachine = animation_tree.get("tree_root")
	
	var attack_node: AnimationNodeBlendTree = animation_state_tree_root.get_node("attack")

	
	if check_buffer && end_timer.time_left > 0:
		if attack_pressed:
			if current_node == "attack":
				state_chart.send_event("swing_2")
		if block_pressed:
			state_chart.send_event("offhand")


func _on_swing_state_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack_primary") && check_buffer:
			attack_pressed = true
	if Input.is_action_pressed("attack_secondary") && check_buffer:
			block_pressed = true


func _on_input_buffer_timeout() -> void:
	check_buffer = true


func _on_end_timer_timeout() -> void:
	if attack_pressed: return
	
	state_chart.send_event("idle")
