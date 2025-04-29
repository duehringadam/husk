class_name jumpingPlayerState
extends State

@export var JUMP_VELOCITY: float = 6
var anim_stored

@onready var walk: AudioStreamPlayer3D = %walk

func enter(previous_state)->void:
	AudioManager.play_sound(load("res://sfx/jump.wav"),Global.player.global_position,-10)
	Global.player.velocity.y += JUMP_VELOCITY
	walk.stop()

func update(delta):
	Global.player.update_gravity(delta)
	Global.player.update_input(delta)
	Global.player.update_velocity()
	
	
	if Global.player.velocity.y < 0:
			transition.emit("fallingPlayerState")
