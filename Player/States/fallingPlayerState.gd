class_name fallingPlayerState
extends State


func enter(previous_state)->void:
	#gun_animation.play("jump",-1,-1,true)
	pass

func update(delta):
	Global.player.update_gravity(delta)
	Global.player.update_input(delta)
	Global.player.update_velocity()
	
	if Global.player.is_on_floor():
		AudioManager.play_sound(load("res://sfx/land.wav"),Global.player.global_position,-20)
		transition.emit("idlePlayerState")
