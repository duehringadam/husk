extends Node

###################
# Hit stop for juice when hitting things
###################
func hit_stop(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
