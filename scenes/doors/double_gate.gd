extends InteractableDoor

var target_rot_1
var target_rot_2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_rot = rotation.y

func set_lock(value: bool):
	locked = value

func interact(controller: InteractionController) -> void:
	var node3D: Node3D = controller.get_parent()
	var interact_pos: Vector3 = node3D.global_position
	
	if is_closed:
		return open(interact_pos)
	else:
		return close()


func open(interact_pos: Vector3 = Vector3.BACK) -> void:
	if !locked:
		disable_collision_shapes = true
		var swing_dir_1: float = sign(self.global_transform.origin.direction_to(interact_pos).dot(Vector3.BACK.rotated(Vector3.UP, global_rotation.y)))
		var swing_dir_2:float = sign(other_door.global_transform.origin.direction_to(interact_pos).dot(Vector3.BACK.rotated(Vector3.UP, other_door.global_rotation.y)))
		target_rot = starting_rot + (deg_to_rad(swing_angle) * swing_dir_1)
		target_rot_1 = starting_rot + (deg_to_rad(swing_angle) * swing_dir_1)
		target_rot_2 = starting_rot + (deg_to_rad(other_door.swing_angle) * swing_dir_2)
		door_activated.emit(true)
		_swing()

func close() -> void:
	#if is_instance_valid(doorclose):
		#doorclose.play()
	target_rot = starting_rot
	target_rot_1 = starting_rot
	target_rot_2 = other_door.starting_rot
	disable_collision_shapes = false
	door_activated.emit(false)
	_swing()


func _swing() -> void:
	if swing_tween:
		swing_tween.kill()
	swing_tween = create_tween()
	swing_tween.finished.connect(_on_tween_finished)
	swing_tween.set_parallel()
	var calc_open_time: float = ((abs(target_rot - rotation.y)) / deg_to_rad(swing_angle)) * open_time
	var duration: float = max(calc_open_time, min_swing_time)
	swing_tween.tween_property(self, "rotation:y", target_rot_1, duration)\
	.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	swing_tween.tween_property(other_door, "rotation:y", target_rot_2, duration)\
	.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	
	disable_collision_shapes = true


func _on_tween_finished() -> void:
	disable_collision_shapes = false
	swing_tween.kill()
