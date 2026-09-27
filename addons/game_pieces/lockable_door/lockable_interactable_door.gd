class_name LockableInteractableDoor extends InteractableDoor

@export var key_needed: item

var _interacting_controller: InteractionController

func lock_door(controller: InteractionController) -> void:
	pass
	#var interaction_container: InteractionContainer = InteractionContainer.from(self)
	#interaction_container.enable(2)
	#controller.refresh_prompts(interaction_container)

func unlock_door(controller: InteractionController) -> void:
	pass


func interact(controller: InteractionController) -> void:
	var node3D: Node3D = controller.get_parent()
	var interact_pos: Vector3 = node3D.global_position
	_interacting_controller = controller
	
	if locked:
		ContextPopUp.set_popup_text("Locked.")
		ContextPopUp.activate()
	
	if is_closed:
		return open(interact_pos)
	else:
		return close()

func open(interact_pos: Vector3 = Vector3.BACK) -> void:
	if !locked:
		if open_sfx:
			open_sfx.play()
		disable_collision_shapes = true
		var swing_dir: float = sign(self.global_transform.origin.direction_to(interact_pos).dot(Vector3.BACK.rotated(Vector3.UP, global_rotation.y)))
		target_rot = starting_rot + (deg_to_rad(swing_angle) * swing_dir)
		_swing()
		door_activated.emit(true)
	

func _on_tween_finished() -> void:
	super._on_tween_finished()
	var interaction_container: InteractionContainer = InteractionContainer.from(self)
	if is_closed:
		interaction_container.enable(0)
		_interacting_controller.refresh_prompts(interaction_container)
	else:
		interaction_container.enable(1)
		_interacting_controller.refresh_prompts(interaction_container)


func _on_padlock_interactable_lock_broken() -> void:
	locked = false
	var interaction_container: InteractionContainer = InteractionContainer.from(self)
	interaction_container.enable(0)
