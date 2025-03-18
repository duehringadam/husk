class_name sprintingPlayerState

extends State

@onready var walk: AudioStreamPlayer3D = %walk


func enter(previous_state)->void:
	Global.player.SPEED = Global.player.SPRINT_SPEED

func update(delta):
	Global.player.update_gravity(delta)
	Global.player.update_input(delta)
	Global.player.update_velocity()
	
	
	if Input.is_action_just_released("sprint"):
		transition.emit("walkingPlayerState")
	if Input.is_action_just_pressed("crouch"):
		transition.emit("crouchingPlayerState")
	if Input.is_action_just_pressed("jump") and Global.player.is_on_floor():
		transition.emit("jumpingPlayerState")
