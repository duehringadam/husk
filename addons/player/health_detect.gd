extends ShapeCast3D

var target: npc : set = _update_target

func _update_target(value: npc):
	if target != value:
		target = value
		if !target.health_component.is_connected("health_changed", update_health):
			target.health_component.connect("health_changed", update_health)
		EnemyManager.emit_signal("enemy_combat_target_changed", target.npc_name, target, target.health_component.max_health, target.health_component.current_health)

func update_health(amount:float, new_value:float):
	EnemyManager.emit_signal("enemy_combat_target_take_damage", amount)

func _physics_process(delta: float) -> void:
	if is_colliding():
		var colliders =  get_collision_count()
		var base_object := get_collider(0)
		for i in colliders:
			if get_collider(i) is npc:
				var check_dist = get_collider(i).global_position.distance_to(Global.player.global_position)
				if check_dist < base_object.global_position.distance_to(Global.player.global_position) && Global.player.camera.is_position_in_frustum(get_collider(i).global_position):
					base_object = get_collider(i)
				target = base_object
