class_name IdlePlayerState

extends State

@onready var weapon: Node3D = %weapon_viewport
@onready var walk: AudioStreamPlayer3D = %walk



func enter(previous_state)->void:
	walk.stop()

func update(delta):
	Global.player.update_gravity(delta)
	Global.player.update_input(delta)
	Global.player.update_velocity()
	
	if Global.player.velocity.length() > 0.0 and Global.player.is_on_floor():
		transition.emit("walkingPlayerState")
	if Input.is_action_just_pressed("crouch") and Global.player.is_on_floor():
		transition.emit("crouchingPlayerState")
	if Input.is_action_just_pressed("jump") and Global.player.is_on_floor():
		transition.emit("jumpingPlayerState")
	if Input.is_action_just_pressed("lean_left"):
		transition.emit("leaningPlayerState")
	if Input.is_action_just_pressed("lean_right"):
		transition.emit("leaningRightPlayerState")
				
			
