class_name NoclipPlayerState

extends State

func enter(previous_state)->void:
	pass

func update(delta):
	Global.player.update_input(delta)
	Global.player.update_velocity()

	
