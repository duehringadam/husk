extends CharacterBody3D

var direction
var SPEED = 4.0
var SPRINT_SPEED = 6

const SPEED_DEFAULT = 4.0
const MOUSE_SENS = 0.003
const JUMP_VELOCITY = 8.0
const CROUCH_SPEED = 3

@onready var animation: AnimationPlayer = %AnimationPlayer
@onready var head: Node3D = $head
@onready var camera: Camera3D = %Camera3D
@onready var weapon: Node3D = %weapon_viewport
@onready var weapon_world: Node3D = $head/Camera3D/sword_world_model


#camera bob
const BOB_FREQ = 2.4
const BOB_AMP = 0.08

const GUN_BOB_FREQ = 2.4
const GUN_BOB_AMP = 0.06
var t_bob = 0.0

var gravity = 18

var can_shoot = true
var dead = false

func _ready() -> void:
	Global.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _input(event: InputEvent) -> void:
	if dead:
		return
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSE_SENS)
		camera.rotate_x(-event.relative.y * MOUSE_SENS)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70),deg_to_rad(70))
	
	if event.is_action_pressed("attack_primary"):
		weapon.animation_player.play("hold_right")
		weapon_world.animation_player.play("hold_right")
	if event.is_action_released("attack_primary"):
		weapon.animation_player.play("swing_right")
		weapon_world.animation_player.play("swing_right")
		

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
			weapon.rotation_degrees.z = lerp(weapon.rotation_degrees.z, clampf(weapon.rotation_degrees.z+velocity.z,-14,-6),delta * 7.0)
			t_bob += delta * velocity.length() * float(is_on_floor())
			camera.transform.origin = _headbob(t_bob)
			weapon.transform.origin = _gunbob(t_bob)
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 7.0)
			weapon.rotation_degrees.z = lerp(weapon.rotation_degrees.z, clampf(weapon.rotation_degrees.z+velocity.z,-14,-6),delta * 7.0)
			t_bob += delta * velocity.length() * float(is_on_floor())
			camera.transform.origin = _headbob(t_bob)
			weapon.transform.origin = _gunbob(t_bob)
			
		if input_dir.x > 0:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(-1), 0.05)
		elif input_dir.x < 0:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(1), 0.05)
		else:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(0), 0.05)
	
func update_velocity():
	move_and_slide()

func shoot_done():
	can_shoot = true

func kill():
	dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _headbob(time) -> Vector3:
	var pos = Vector3(0,0,0)
	pos.y += sin(time * BOB_FREQ) * BOB_AMP 
	return pos

func _gunbob(time) -> Vector3:
	var pos = Vector3(0.8,0-.3,-1.1)
	pos.y += sin(time * GUN_BOB_FREQ) * GUN_BOB_AMP
	return pos
