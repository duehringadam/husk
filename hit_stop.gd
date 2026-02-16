extends Node

###################
# Hit stop for juice when hitting things
###################
var current_priority: int

func hit_stop(timeScale, duration, priority: int):
	if priority > current_priority:
		current_priority = priority
		Engine.time_scale = timeScale
		await get_tree().create_timer(duration, true, false, true).timeout
		Engine.time_scale = 1.0
		current_priority = 0
