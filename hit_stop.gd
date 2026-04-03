extends Node

###################
# Hit stop for juice when hitting things
###################
var current_priority: int
var times_activated: int = 0
var timer = Timer.new()

func _ready() -> void:
	timer.wait_time = 1
	timer.ignore_time_scale = true
	timer.one_shot = true
	timer.timeout.connect(func(): times_activated = 0)
	add_child(timer)

func hit_stop(timeScale, duration, priority: int):
	timer.start()
	if times_activated > 2: return
	times_activated += 1
	if priority > current_priority:
		current_priority = priority
		Engine.time_scale = timeScale
		await get_tree().create_timer(duration, true, false, true).timeout
		Engine.time_scale = 1.0
		current_priority = 0
