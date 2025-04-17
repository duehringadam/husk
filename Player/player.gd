class_name Player
extends CharacterBody3D

var direction
var SPEED = 4.0
var SPRINT_SPEED = 6

const SPEED_DEFAULT = 4.0
const MOUSE_SENS = 0.003
const JUMP_VELOCITY = 8.0
const CROUCH_SPEED = 3

@export var mainhand: Node3D
@export var offhand: Node3D

@onready var animation: AnimationPlayer = %AnimationPlayer
@onready var head: Node3D = $head
@onready var camera: Camera3D = %main_camera
@onready var state_machine: StateMachine = $stateMachine
@onready var inventory_vbox: VBoxContainer = $UILayer/userInterface/uiMargin/inventory/PanelContainer/ScrollContainer/VBoxContainer


#camera bob
const BOB_FREQ = 2.4
const BOB_AMP = 0.04

const GUN_BOB_FREQ = 2.4
const GUN_BOB_AMP = 0.04

const LANTERN_BOB_FREQ = 2.4
const LANTERN_BOB_AMP = 0.02

var t_bob = 0.0

var gravity = 18

var dead = false
var can_attack_bool: bool = true
var secondary_active_bool: bool = false
var primary_active_bool: bool = false
var blocking: bool = false


func _ready() -> void:
	Global.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _input(event: InputEvent) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dead:
		return
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSE_SENS)
		camera.rotate_x(-event.relative.y * MOUSE_SENS)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70),deg_to_rad(70))


func _process(delta: float) -> void:
	if dead:
		return
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		#restart()
		kill()

func restart():
	get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	if dead:
		return

func update_gravity(delta)->void:
	velocity.y -= gravity * delta

func update_input(delta) ->void:
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			mainhand.rotation_degrees.z = lerp(mainhand.rotation_degrees.z, clampf(mainhand.rotation_degrees.z+velocity.z,-10,6),delta * 7.0)
			offhand.rotation_degrees.z = lerp(offhand.rotation_degrees.z, clampf(offhand.rotation_degrees.z-velocity.z,-10,6),delta * 3.5)
			t_bob += delta * velocity.length() * float(is_on_floor())
			camera.transform.origin = _headbob(t_bob)
			mainhand.transform.origin = _gunbob(t_bob)
			offhand.transform.origin = _offhandbob(t_bob)
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 7.0)
			mainhand.rotation_degrees.z = lerp(mainhand.rotation_degrees.z, clampf(mainhand.rotation_degrees.z+velocity.z,-10,6),delta * 7.0)
			offhand.rotation_degrees.z = lerp(offhand.rotation_degrees.z, clampf(offhand.rotation_degrees.z-velocity.z,-10,6),delta * 3.5)
			t_bob += delta * velocity.length() * float(is_on_floor())
			camera.transform.origin = _headbob(t_bob)
			mainhand.transform.origin = _gunbob(t_bob)
			offhand.transform.origin = _offhandbob(t_bob)
			
		if input_dir.x > 0:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(-1), 0.06)
		elif input_dir.x < 0:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(1), 0.06)
		else:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(0), 0.06)
	
func update_velocity():
	move_and_slide()

func kill():
	dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _headbob(time) -> Vector3:
	var pos = Vector3(0,0,0)
	pos.y += sin(time * BOB_FREQ) * BOB_AMP 
	return pos

func _gunbob(time) -> Vector3:
	var pos = Vector3(.6,-.3,-.7)
	pos.y += sin(time * GUN_BOB_FREQ) * GUN_BOB_AMP
	pos.x += sin(-time * GUN_BOB_FREQ) * GUN_BOB_AMP
	return pos

func _offhandbob(time) -> Vector3:
	var pos = Vector3(-.6,-.6,-.9)
	pos.y += sin(time * LANTERN_BOB_FREQ) * LANTERN_BOB_AMP
	return pos


func _on_health_component_died() -> void:
	state_machine.CURRENT_STATE.transition.emit("dyingPlayerState")
