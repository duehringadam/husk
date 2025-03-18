extends State

class_name leaningRightPlayerState

@onready var ray_cast_3d: RayCast3D = $"../../head/Camera3D/RayCast3D"
@onready var ray_cast_3d_2: RayCast3D = $"../../head/Camera3D/RayCast3D2"


func enter(previous_state):
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(Global.player.camera,"rotation:z",-.05,.5)
	tween.parallel().tween_property(Global.player.camera,"h_offset",.5,.5)
	
func update(delta):
	Global.player.update_gravity(delta)
	Global.player.update_input(delta)
	Global.player.update_velocity()
	
	if Input.is_action_just_released("lean_right"):
		exit()
		transition.emit("idlePlayerState")
	if ray_cast_3d.is_colliding() or ray_cast_3d_2.is_colliding():
		exit()
		transition.emit("idlePlayerState")

func exit():
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(Global.player.camera,"rotation:z",0,.5)
	tween.parallel().tween_property(Global.player.camera,"h_offset",0,.5)
	
