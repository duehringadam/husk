#class_name Player
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
@export var body:Node3D

@export var weapon_sway_amount : float = 5
@export var weapon_rotation_amount : float = 1
@export var invert_weapon_sway : bool = false

@onready var lookat_ray: RayCast3D = $head/main_camera/look_at_ray
@onready var animation: AnimationPlayer = %AnimationPlayer
@onready var head: Node3D = $head
@onready var camera: Camera3D = %main_camera
@onready var viewport_camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D
@onready var state_machine: StateMachine = $stateMachine
@onready var inventory_vbox: VBoxContainer = $UILayer/userInterface/uiMargin/inventory/PanelContainer/ScrollContainer/VBoxContainer
@onready var sub_viewport: SubViewport = %SubViewport
@onready var hitbox: CollisionShape3D = $hitbox
@onready var carry: Node3D = %carry
@onready var carry_transform: RemoteTransform3D = %carryTransform


#camera bob
const BOB_FREQ = 2.4
const BOB_AMP = 0.04

const GUN_BOB_FREQ = 2.4
const GUN_BOB_AMP = 0.04

const LANTERN_BOB_FREQ = 2.4
const LANTERN_BOB_AMP = 0.04

var t_bob = 0.0

var gravity = 18

var dead = false
var can_attack_bool: bool = true
var secondary_active_bool: bool = false
var primary_active_bool: bool = false
var blocking: bool = false
var input_dir
var noclip := false
var mouse_movement: Vector2

var mainhand_weapon_holder_pos : Vector3
var offhand_weapon_holder_pos : Vector3

func _ready() -> void:
	Global.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	SignalBus.connect("is_blocking",is_blocking)
	mainhand_weapon_holder_pos = mainhand.position
	offhand_weapon_holder_pos = offhand.position

func is_blocking(value:bool):
	blocking = value

func _unhandled_input(event: InputEvent) -> void:
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dead:
		return
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSE_SENS)
		camera.rotate_x(-event.relative.y * MOUSE_SENS)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70),deg_to_rad(70))
		mouse_movement = event.relative


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
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			t_bob += delta * velocity.length() * float(is_on_floor())
			camera.transform.origin = _headbob(t_bob)
			body.transform.origin = _gunbob(t_bob)
			
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 7.0)
			t_bob += delta * velocity.length() * float(is_on_floor())
			camera.transform.origin = _headbob(t_bob)
			body.transform.origin = _gunbob(t_bob)
			
		if input_dir.x > 0:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(-2.5), 0.1)
		elif input_dir.x < 0:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(2.5), 0.1)
		else:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(0), 0.1)
	weapon_tilt(input_dir.x, delta)
	weapon_sway(delta)
	
func update_velocity():
	move_and_slide()

func weapon_tilt(input_x, delta):
	if mainhand:
		mainhand.rotation.z = lerpf(mainhand.rotation.z, clampf(-input_x * weapon_rotation_amount * 10,-.3,.3), 5 * delta)
	if offhand:
		offhand.rotation.z = lerpf(offhand.rotation.z, clampf(-input_x * weapon_rotation_amount * 10,-.3,.3), 5 * delta)

func weapon_sway(delta):
	mouse_movement = lerp(mouse_movement,Vector2.ZERO,10*delta)
	if mainhand:
		mainhand.rotation.x = lerpf(mainhand.rotation.x, clampf(mouse_movement.y * weapon_rotation_amount * (-1 if invert_weapon_sway else 1),-.1,.1), 5 * delta)
		mainhand.rotation.y = lerpf(mainhand.rotation.y, clampf(mouse_movement.x * weapon_rotation_amount * (-1 if invert_weapon_sway else 1),-.1,.1), 5 * delta)
	if offhand:
		offhand.rotation.x = lerpf(offhand.rotation.x, clampf(mouse_movement.x * weapon_rotation_amount * (-1 if invert_weapon_sway else 1),-.1,.1), 5 * delta)
		offhand.rotation.y = lerpf(offhand.rotation.y, clampf(mouse_movement.y * weapon_rotation_amount * (-1 if invert_weapon_sway else 1),-.1,.1), 5 * delta)
	
func kill():
	dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _headbob(time) -> Vector3:
	var pos = Vector3(0,0,0)
	pos.y += sin(time * BOB_FREQ) * BOB_AMP 
	pos.x += sin(time * BOB_FREQ) * BOB_AMP 
	return pos

func _gunbob(time) -> Vector3:
	var pos = Vector3(0,-0.1,0)
	pos.y += sin(time * GUN_BOB_FREQ) * GUN_BOB_AMP
	
	return pos

func _offhandbob(time) -> Vector3:
	var pos = Vector3(-.441,-.298,-.565)
	pos.y += sin(time * LANTERN_BOB_FREQ) * LANTERN_BOB_AMP

	return pos
	


func _on_health_component_died() -> void:
	state_machine.CURRENT_STATE.transition.emit("dyingPlayerState")
