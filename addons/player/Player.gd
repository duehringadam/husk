@tool
## Stuff here?
class_name Player extends CharacterBody3D
@export_category("Inventory")
@export var inventory: Array[item]
@export var footsteps_sound: AudioStream

## The constant value that footsteps and head bob are calculated against
const BASE_WALK_SPEED: float = 3.0
const BOB_FREQ: float = BASE_WALK_SPEED
const LEAN_SPEED: float = 0.1

@export_category("User Settings")
## Look/Mouse sensitivity
@export var mouse_sensitivity: float = 4.0

## How much head bobs
@export var head_bob_strength: float = 0.025

## Base FOV Setting
@export var base_fov: float = 75.0
@export var toggle_crouch: bool = true

@export_category("Other Configuration")
@export_group("Player Body")
@export var player_body: Node3D
@export_group("Movement")
@export var walk_speed = 3.0: set = _set_walk_speed
@export var sprint_speed: float = 6.0: set = _set_sprint_speed
@export var crouch_speed = 1.5
@export var jump_power: float = 4
## How much fov changes from base value based on current velocity
@export var fov_change: float = 1
## To disable sprint for when player runs out of stamina for example
@export var disable_sprint: bool = false
@export_group("Crouching")
@export var full_height: float = 1.
@export var crouch_height: float = .5
## Time it takes to crouch or stand back up
@export var crouch_time: float = 0.16
@export_group("Leaning")
@export var camera_base_position: Vector3 = Vector3.ZERO
@export var camera_lean_position: Vector3 = Vector3(1., -0.1, 0.)
@export_group("Other")
@export var lock_camera: bool = false

@export_category("Info")
@export_custom(PROPERTY_HINT_MULTILINE_TEXT, "", PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_EDITOR)
var _1: String = "Player node requires uniquely named children inheriting from GameControl.
Required: %look, %move.
Optional: %jump, %sprint, %crouch, %lean, %zoom, %switch_hands
"

@export_category("Weapon")
@export var mainhand: Node3D
@export var offhand: Node3D
@export var weapon_sway_amount : float = 5
@export var weapon_rotation_amount : float = 1
@export var invert_weapon_sway : bool = false

## Control where x and z values will control the movement direction of the player
## The value_3d must have a value of (0, 0, -1) for moving forward
## and a value of (1, 0, 0) for moving/strafing right
## only x and z are used. y is discarded.
@onready var move_control: GameControl = %move
## Control where x and y values will control the look direction of the player
## x and y values must represent the delta mouse position as window-relative units between 0 and 1
## E.g. if a mouse cursor moves half a screen to the right and down, then 
## this modifier will return (0.5, 0.5).
@onready var look_control: GameControl = %look

@onready var head: Node3D = %Head
@onready var neck: Node3D = %Neck
@onready var camera: Camera3D = %Camera3D
@onready var footsteps: AudioStreamPlayer3D = %FootSteps
@onready var foot_steps_animation_player: AnimationPlayer = %FootStepsAnimationPlayer
@onready var camera_animation_player: AnimationPlayer = %CameraAnimationPlayer
@onready var ceiling: ShapeCast3D = $Ceiling
@onready var right_hand_pos: Vector3 = %RightHand.transform.origin
@onready var left_hand_pos: Vector3 = %LeftHand.transform.origin
@onready var enemy_look_at: Node3D = $enemy_look_at


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = 9.8
var speed: float
var on_floor_last_frame: bool = false
var bob_time: float = 0.0
var crouch_released_last_frame: bool = true
var crouching: bool:
	get():
		return abs(scale.y - crouch_height) < 0.01

var facing: Vector3:
	get():
		return -camera.global_basis.z


var _crouch_tween: Tween
var _switched: bool = false
var isLooking : bool
const LOOK_AT_DURATION := 1
var look_target: Node3D
var mouse_movement: Vector2
var input_dir: Vector3
var can_move:=true

const WALK_SPEED_MINIMUM := 3.0
const WALK_SPEED_MAXIMUM := 4.0

const SPRINT_SPEED_MIN := 4.0
const SPRINT_SPEED_MAX := 6.0

func _ready() -> void:
	SignalBus.connect("primary_active", _animate_camera_swing)
	SignalBus.connect("kick_active", _animate_camera_swing)
	Global.camera_fov = base_fov
	if Engine.is_editor_hint(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	footsteps.stream = footsteps_sound
	if inventory.size() > 0:
		for i in inventory:
			SignalBus.emit_signal("item_interact", i)
	
func _animate_camera_swing(value: bool):
	if value:
		camera_animation_player.play("swing_left")
	
func _set_walk_speed(value: float):
	walk_speed = clampf(value,WALK_SPEED_MINIMUM, WALK_SPEED_MAXIMUM)
	
func _set_sprint_speed(value:float):
	sprint_speed = clampf(value, SPRINT_SPEED_MIN, SPRINT_SPEED_MAX)

func _physics_process(delta) -> void:
	if Engine.is_editor_hint(): return
	handle_effects(delta)
	handle_falling(delta)
	handle_jump()
	handle_crouch(delta)
	set_movement_speed()
	handle_movement(delta)
	handle_head_bob(delta)
	handle_zoom(delta)
	handle_switch_hands()
	handle_lean(delta)
	move_and_slide()
	weapon_sway(delta)
	handle_kick()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
		look_around()
		
func handle_effects(delta) -> void:
	
	if is_on_floor():
		var horizontal_velocity: Vector2 = Vector2(velocity.x, velocity.z)
		var speed_factor: float = horizontal_velocity.length() / BASE_WALK_SPEED
		foot_steps_animation_player.speed_scale = speed_factor
	else:
		foot_steps_animation_player.speed_scale = 0.0

func handle_kick():
	if get_node_or_null("%kick") != null and %kick.is_triggered() and is_on_floor():
		player_body.kick()

func handle_falling(delta: float) -> void:
	if not on_floor_last_frame and is_on_floor():
		footsteps.play()
		camera_animation_player.play("land")
	on_floor_last_frame = is_on_floor()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta


func handle_jump() -> void:
	if get_node_or_null("%jump") != null and %jump.is_triggered() and is_on_floor():
		velocity.y = jump_power
		footsteps.play()
		camera_animation_player.play("jump")


func handle_crouch(delta: float) -> void:
	var crouch_pressed: bool = get_node_or_null("%crouch") != null and %crouch.is_triggered()
	if toggle_crouch:
		if crouch_pressed:
			toggle_crouch_state()
	else:
		if crouch_pressed and not crouching:
			set_crouch(true)
		elif not crouch_pressed and crouching:
			set_crouch(false)
	crouch_released_last_frame = not crouch_pressed


func toggle_crouch_state() -> void:
	if not crouch_released_last_frame: return
	set_crouch(not crouching)


func set_crouch(enable: bool) -> void:
	player_body.crouch(enable)
	if _crouch_tween != null:
		_crouch_tween.kill()
	if enable:
		_crouch_tween = create_tween()
		_crouch_tween.tween_property(self, "scale", Vector3.ONE * crouch_height, crouch_time)
	elif not ceiling.is_colliding():
		_crouch_tween = create_tween()
		_crouch_tween.tween_property(self, "scale", Vector3.ONE * full_height, crouch_time)

func set_movement_speed() -> void:
	if !can_move: speed = 0; return
	
	if player_body.is_kicking:
		speed = 0
		return
	if get_node_or_null("%sprint") != null and %sprint.is_triggered() and not disable_sprint:
		speed = sprint_speed
	else:
		speed = walk_speed
	
	if crouching:
		speed = crouch_speed
	footsteps.volume_linear = speed / walk_speed


func look_around() -> void:
	if lock_camera: return
	head.rotate_y(look_control.value_axis_2d().x * mouse_sensitivity)
	neck.rotate_x(look_control.value_axis_2d().y * mouse_sensitivity)
	neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-75), deg_to_rad(60))


func handle_movement(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	input_dir = move_control.value_axis_3d()
	player_body.movement_dir.x = input_dir.x
	player_body.movement_dir.y = input_dir.z
	weapon_tilt(input_dir.x, delta)
	
	var direction: Vector3 = (head.transform.basis * transform.basis * input_dir).normalized()
	if is_on_floor():
		
		#if floor_normal.angle_to(Vector3.UP) > deg_to_rad(floor_max_angle):
			#velocity.x = 0
			#velocity.z = 0
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			handle_fov_change(delta)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)


func handle_head_bob(delta: float) -> void:
	bob_time += delta * velocity.length() * float(is_on_floor())
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(bob_time * BOB_FREQ) * head_bob_strength
	pos.x = cos(bob_time * BOB_FREQ / 2) * head_bob_strength
	neck.transform.origin =  pos
	%RightHand.transform.origin = right_hand_pos - pos / 4
	%LeftHand.transform.origin = left_hand_pos - pos / 4


func handle_fov_change(delta: float) -> void:
	var velocity_clamped: float = clamp(Vector2(velocity.x, velocity.z).length(), 0.5, sprint_speed * 2)
	var target_fov: float = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)


func handle_zoom(delta: float) -> void:
	if get_node_or_null("%zoom") == null: return
	var target_fov: float = camera.fov * .33 if %zoom.is_triggered() else camera.fov
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)


func handle_switch_hands() -> void:
	if get_node_or_null("%switch_hands") == null: return
	if not %switch_hands.is_triggered(): 
		_switched = false
		return
	if _switched: return
	_switched = true
	var right_items: Array = %RightHand.get_children()
	var left_items: Array = %LeftHand.get_children()
	for item: Node in right_items:
		item.reparent(%LeftHand, false)
	for item: Node in left_items:
		item.reparent(%RightHand, false)


func handle_lean(delta: float) -> void:
	if get_node_or_null("%lean") == null: return
	var lean_control: GameControl = %lean
	var lean_value = lean_control.value()
	
	var lean_target_position = Vector3(
		lean_value * camera_lean_position.x,
		camera_base_position.y if lean_value == 0 else camera_lean_position.y,
		camera_base_position.z
	)
	camera.position = lerp(camera.position, lean_target_position, LEAN_SPEED)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if %look == null:
		warnings.append("Add a unique named 'look' PlayerControl child to the player")
	if %move == null:
		warnings.append("Add a unique named 'move' PlayerControl child to the player")
	return warnings
	
func _y_rotate(to: float) -> float:
	# find shortest distance to loop so it doesn't go full circle
	# in situtations like 350 deg to 10 deg.
	var difference = fmod(to - rotation.y, PI * 2)
	return fmod(2 * difference, PI * 2) - difference

func cutscene():
	isLooking = true
	smooth_lookat()
	await get_tree().create_timer(99).timeout
	ResumeControl()

func ResumeControl():
	isLooking = false
	
func smooth_lookat():
	if isLooking:
		# look at logic
		var target_global_pos := look_target.global_position
		var camera_basis := Basis.looking_at(target_global_pos - camera.global_position)
		var rotations = camera_basis.get_euler()
		# reset rotations except X
		camera_basis = camera_basis.rotated(Vector3.UP, -rotations.y)
		camera_basis = camera_basis.rotated(Vector3.BACK, -rotations.z)

		var dir = global_position - target_global_pos
		var angle = atan2(dir.x, dir.z)
		var new_rotation = Vector3(
			rotation.x,
			rotation.y +_y_rotate(angle),
			rotation.z,
		)

		var tween = create_tween().set_parallel(true)
		tween.set_trans(Tween.TRANS_QUART)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(camera, "basis", camera_basis, LOOK_AT_DURATION)
		tween.tween_property(self, "rotation", new_rotation, LOOK_AT_DURATION)
		
func weapon_tilt(input_x, delta):
	if mainhand:
		mainhand.rotation.z = lerpf(mainhand.rotation.z, clampf(-input_x * weapon_rotation_amount * 10,-.05,.05), 5 * delta)
	if offhand:
		offhand.rotation.z = lerpf(offhand.rotation.z, clampf(-input_x * weapon_rotation_amount * 10,-.05,.05), 5 * delta)
	
func weapon_sway(delta):
	mouse_movement = lerp(mouse_movement,Vector2.ZERO,10*delta)
	if mainhand:
		mainhand.rotation.x = lerpf(mainhand.rotation.x, clampf(mouse_movement.y * weapon_rotation_amount * (-1 if invert_weapon_sway else 1),-.4,.4), delta)
		#mainhand.rotation.y = lerpf(mainhand.rotation.y, clampf(mouse_movement.y * weapon_rotation_amount * (-1 if invert_weapon_sway else 1),-.4,.4), delta)
	if offhand:
		offhand.rotation.x = lerpf(offhand.rotation.x, clampf(mouse_movement.y * weapon_rotation_amount * (1 if invert_weapon_sway else -1),-.04,.04), delta)
		offhand.rotation.y = lerpf(offhand.rotation.y, clampf(mouse_movement.y * weapon_rotation_amount * (1 if invert_weapon_sway else -1),-.04,.04), delta)


func _on_hurtbox_component_damage_taken(actual: float, source: DamageComponent, hit_dir: Vector3) -> void:
	camera_animation_player.play("swing_left",-1,1.5)
