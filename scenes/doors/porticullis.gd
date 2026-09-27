class_name Porticullis
extends InteractableDoor

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
		open_sfx.play()
		disable_collision_shapes = true
		_swing()
	#else:
		#doorlocked.play()


func close() -> void:
	if is_instance_valid(close_sfx):
		close_sfx.play()
	disable_collision_shapes = false
	_swing()

func _swing() -> void:
	if swing_tween:
		swing_tween.kill()
	swing_tween = create_tween()
	swing_tween.finished.connect(_on_tween_finished)
	
	swing_tween.tween_property(self, "position:y", position.y + 4.0, 3)\
	.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	
	#disable_collision_shapes = true
