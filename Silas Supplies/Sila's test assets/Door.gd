class_name Door
extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var IsOpen = false

func open():
	animation_player.play("Door_Open")

func closed():
	animation_player.play("Door_Open", -1, -1, true)

func activate():
	
	if IsOpen:
		IsOpen = !IsOpen
		closed()
	else:
		IsOpen = !IsOpen
		open()
