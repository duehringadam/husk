class_name walkingPlayerState
extends State
var previous_state

@onready var walk: AudioStreamPlayer3D = %walk


func enter(previous_state)->void:
	Global.player.SPEED = Global.player.SPEED_DEFAULT
	walk.play()

func update(delta):
	Global.player.update_gravity(delta)
	Global.player.update_input(delta)
	Global.player.update_velocity()
	
	
	if Global.player.velocity.length() < 1.0 and Global.player.is_on_floor():
		transition.emit("idlePlayerState")
	if Input.is_action_pressed("sprint") and Global.player.is_on_floor():
		transition.emit("sprintingPlayerState")
	if Input.is_action_just_pressed("crouch") and Global.player.is_on_floor():
		transition.emit("crouchingPlayerState")
	if Input.is_action_just_pressed("jump") and Global.player.is_on_floor():
		transition.emit("jumpingPlayerState")
