class_name crouchingPlayerState
extends State

@onready var CROUCH_SHAPECAST: ShapeCast3D = %ShapeCast3D
@onready var walk: AudioStreamPlayer3D = %walk

func enter(previous_state)->void:
	animation.play("crouch",0,2)
	Global.player.SPEED = Global.player.CROUCH_SPEED
	walk.play()

func update(delta):
	Global.player.update_gravity(delta)
	Global.player.update_input(delta)
	Global.player.update_velocity()
	if Input.is_action_just_released("crouch"):
		uncrouch()
	if Input.is_action_just_pressed("jump") and Global.player.is_on_floor():
		transition.emit("jumpingPlayerState")

func uncrouch():
	if CROUCH_SHAPECAST.is_colliding() == false:
		animation.play("crouch",0,-2, true)
		if animation.is_playing():
			await animation.animation_finished
		transition.emit("idlePlayerState")
	elif CROUCH_SHAPECAST.is_colliding() == true:
		await  get_tree().create_timer(0.001).timeout
		uncrouch()
