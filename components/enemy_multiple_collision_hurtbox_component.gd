class_name enemy_multiple_collision_hurtbox_component
extends hurtbox_component

signal damage_blocked
signal damage_types_taken(damage_types: Dictionary[DamageTypes.DAMAGE_TYPES, float])

var local_shape_idx: int
var just_damaged:bool = false
var limb_collider

func take_damage(damage_types: Dictionary[DamageTypes.DAMAGE_TYPES, float], status_types: Dictionary[Global.STATUS_TYPE, float], stance_damage: float, source: DamageComponent):
	var hit_dir = (global_position.direction_to(source.global_position)).normalized()
	# take damage
	var sum := 0.0
	if is_facing(source) && is_blocking:
		damage_blocked.emit()
		if stance_component != null:
			stance_component.modify_stance(-stance_damage, source)
		return 0
	for i in damage_types:
			var actual = modify_damage(i,damage_types[i], source)
			if status_types.size() != 0:
				apply_status(status_types)
			emit_signal("damage_taken", actual, source, hit_dir)
			if health_component:
				health_component.modify_health(-actual)
				health_component.damage_source = source.source
			limb_collider = get_child(local_shape_idx)
			limb_collider.bone_take_damage(damage_types, actual)
			sum += actual
	damage_types_taken.emit(damage_types)
	if stance_component != null:
		stance_component.modify_stance(-stance_damage, source)
	if status_component != null:
		for i in status_types:
			if status_resistances.keys().has(i):
				status_component._on_status_increment(i,(1-status_resistances[i]))
			if status_weaknesses.keys().has(i):
				status_component._on_status_increment(i,(1*status_weaknesses[i]))
	if hit_sound != null:
		AudioManager.play_sound(hit_sound,self.global_position,-10.0)
	if damage_particles:
		damage_particles_add = damage_particles.instantiate()
		get_tree().current_scene.add_child(damage_particles_add)
		damage_particles_add.global_position = limb_collider.global_position
		get_tree().create_timer(.1).timeout.connect(func(): damage_particles_add.take_damage())
	return sum


func _on_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, _local_shape_index: int) -> void:
	if area is DamageComponent && !just_damaged:
		just_damaged = true
		local_shape_idx = _local_shape_index
		get_tree().create_timer(.25).timeout.connect(func(): just_damaged = false)

func is_facing(source: DamageComponent) -> bool:
	if source.source:
		var self_forward = self.global_transform.basis.z 
		var target_direction = (source.source.global_transform.origin - self.global_transform.origin).normalized()
		var dot_product = self_forward.dot(target_direction)
		var angle_to_target = acos(dot_product)
		if angle_to_target < deg_to_rad(90):
			return true
		return false
	return false
