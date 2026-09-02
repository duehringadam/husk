extends Node

@export var state_chart: StateChart
@export var bone_attach: BoneAttachment3D
@export var animation_tree: AnimationTree
@export var hand: Node3D
@onready var input_buffer_timer: Timer = $"../inputBufferTimer"

var weapon
var input_dict: Dictionary[String, Vector2]
var attack_pressed: bool = false
var check_buffer: bool = false
var block_pressed: bool = false
func _ready() -> void:
	animation_tree["parameters/playback"].connect("state_finished", _anim_finished)

func _on_swing_left_state_entered() -> void:
	input_buffer_timer.start()
	Global.player.stamina_component.modify_stamina(-hand.weapon.stamina_cost)
	animation_tree.set("parameters/conditions/swing", true)
	for i in bone_attach.get_children():
		if i is Weapon:
			weapon = i
	if weapon:
		if weapon.swing_sound:
			weapon.swing_sound.pitch_scale = randf_range(0.9,1.1)
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
	check_buffer = false
	input_dict

func _on_swing_state_input(event: InputEvent) -> void:
	var direction_buffer = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	input_dict["direction"] = direction_buffer
	
	if Input.is_action_just_pressed("attack_primary"):
		attack_pressed = true
	if Input.is_action_just_pressed("attack_secondary"):
		block_pressed = true

func _on_swing_state_physics_processing(delta: float) -> void:
	
	var state_machine_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
	var current_node: StringName = state_machine_playback.get_current_node()
	
	var total_length: float = state_machine_playback.get_current_length()
	var current_pos: float = state_machine_playback.get_current_play_position()
	var time_left: float = total_length - current_pos
	
	if time_left <= (total_length/2.0):
		check_buffer = true
		weapon.trail.visible = false
	
	if check_buffer:
		if attack_pressed:
			var dir: Vector2 = input_dict["direction"]
			if dir.y < -.5 && !current_node.contains("swing_forward"):
				state_chart.send_event("hold_forward")
				
			elif dir.y > .5 && !current_node.contains("swing_back"):
				state_chart.send_event("hold_back")
				
			elif dir.x < -0.5 && !current_node.contains("swing_left"):
				state_chart.send_event("hold_right")
				
			elif dir.x > 0.5 && !current_node.contains("swing_right"):
				state_chart.send_event("hold_left")
				
		if block_pressed:
			state_chart.send_event("block")
	
func _anim_finished(state: StringName):
	if state == "swing_right":
		state_chart.send_event("idle")
	if state == "swing_left":
		state_chart.send_event("idle")
	if state == "swing_forward":
		state_chart.send_event("idle")
	if state == "swing_back":
		state_chart.send_event("idle")
	

func _check_input_buffer():
	check_buffer = true
	

func _on_input_buffer_timer_timeout() -> void:
	attack_pressed = false
	block_pressed = false
