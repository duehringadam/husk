class_name multiple_collision_hurtbox_component
extends hurtbox_component

var local_shape_idx: int
var just_damaged:bool = false

func take_damage(damage_types: Dictionary[DamageTypes.DAMAGE_TYPES, float], status_types: Dictionary[Global.STATUS_TYPE, float], stance_damage: float, source: DamageComponent):
	var hit_dir = (global_position.direction_to(source.global_position)).normalized()
	# take damage
	var sum := 0.0
	for i in damage_types:
			var actual = modify_damage(i,damage_types[i], source)
			if status_types.size() != 0:
				apply_status(status_types)
			emit_signal("damage_taken", actual, source, hit_dir)
			if health_component:
				health_component.modify_health(-actual)
				health_component.damage_source = source.source
			var limb_collider = get_child(local_shape_idx)
			limb_collider.bone_take_damage(damage_types, actual)
			sum += actual
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
		damage_particles_add.global_position = self.global_position
		get_tree().create_timer(.1).timeout.connect(func(): damage_particles_add.take_damage())
	return sum


func _on_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, _local_shape_index: int) -> void:
	if area is DamageComponent && !just_damaged:
		just_damaged = true
		local_shape_idx = _local_shape_index
		get_tree().create_timer(.25).timeout.connect(func(): just_damaged = false)
