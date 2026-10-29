extends Node

@export var state_chart: StateChart
@export var bone_attach: BoneAttachment3D
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var hand: Node3D

@onready var input_buffer: Timer = $"../inputBuffer"
@onready var end_timer: Timer = $"../endTimer"

var weapon
var check_buffer: bool = false
var block_pressed: bool = false

func _on_swing_3_state_entered() -> void:
	end_timer.start()
	input_buffer.start()
	Global.player.stamina_component.modify_stamina(-40)
	animation_tree["parameters/attackBlendTree/Transition/transition_request"] = "attack_3"
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
	pass


func _on_swing_3_state_input(event: InputEvent) -> void:
	if Input.is_action_pressed("attack_secondary") && check_buffer:
				block_pressed = true


func _on_swing_3_state_physics_processing(delta: float) -> void:
	if check_buffer && end_timer.time_left > 0:
			if block_pressed:
				state_chart.send_event("offhand")


func _on_end_timer_timeout() -> void:
	state_chart.send_event("idle")


func _on_input_buffer_timeout() -> void:
	pass # Replace with function body.
