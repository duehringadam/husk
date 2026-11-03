extends status_effect_component

@export var decay_time: float = 5.0
signal statuses_increased(statuses: Dictionary[int,float])


func _ready() -> void:
	if hurtbox != null:
		if !hurtbox.is_connected("apply_statuses", _on_status_increment):
			hurtbox.connect("apply_statuses", _on_status_increment)
	if health_component != null:
		if !health_component.is_connected("died", _on_death):
			health_component.connect("died", _on_death)
	resistance_timer = Timer.new()
	add_child(resistance_timer)
	add_child(decay_timer)
	decay_timer.one_shot = true
	decay_timer.wait_time = 5.0
	resistance_timer.one_shot = true
	resistance_timer.timeout.connect(func(): times_applied = 1)
	decay_timer.timeout.connect(status_decay)

func _on_status_increment(status_type: Global.STATUS_TYPE, application_amount: float):
	if !available_statuses.keys().has(status_type):
		return
	else:
		if available_statuses[status_type] < 1:
			available_statuses[status_type] += (application_amount/times_applied)
			resistance_timer.wait_time = 10 * times_applied
			resistance_timer.start()
			decay_timer.start()
			if decay_tween:
				decay_tween.kill()
			statuses_increased.emit(available_statuses)
			if available_statuses[status_type] >= 1.0:
				if !statuses.keys().has(status_type):
					statuses[status_type] = check_status_type(status_type)
					_apply_statuses(statuses.values())
					times_applied += 1

func _apply_statuses(effects: Array[status_effect]):
	if effects.size() == 0:
		return
	status_activated.emit(effects)
	if effects.size() > 0:
		for i: status_effect in effects:
			if i.damage_component_scene != null:
				child_damage_component = i.damage_component_scene.instantiate()
				add_child(child_damage_component)
				child_damage_component.owner = self.owner
			var material_overlay = mesh_to_affect.material_overlay
			material_overlay["shader_parameter/ember_core"] = i.ember_core
			material_overlay["shader_parameter/ember_mid"] = i.ember_mid
			material_overlay["shader_parameter/ember_edge"] = i.ember_edge
			material_overlay["shader_parameter/char_color"] = i.char_color
			material_overlay["shader_parameter/progress"] = i.progress
			material_overlay["shader_parameter/wave_density"] = i.wave_density
			material_overlay["shader_parameter/wave_speed"] = i.wave_speed
			material_overlay["shader_parameter/wave_amplitude"] = i.wave_amplitude
			material_overlay["shader_parameter/ember_brightness"] = i.ember_brightness
			material_overlay["shader_parameter/noise_scale"] = i.noise_scale
			material_overlay["shader_parameter/edge_sharpness"] = i.edge_sharpness
			material_overlay["shader_parameter/char_opacity"] = i.char_opacity
			material_overlay["shader_parameter/turbulence"] = i.turbulence
			material_overlay["shader_parameter/flicker_speed"] = i.flicker_speed
			material_overlay["shader_parameter/time_scale_noise_slow"] = i.time_scale_noise_slow
			material_overlay["shader_parameter/time_scale_noise_fast"] = i.time_scale_noise_fast
			material_overlay["shader_parameter/time_scale_turbulence"] = i.time_scale_turbulence
			material_overlay["shader_parameter/time_scale_flicker"] = i.time_scale_flicker


func check_status_type(status: Global.STATUS_TYPE) -> status_effect:
	match status:
		Global.STATUS_TYPE.BURNING:
			get_tree().create_timer(burning_preload.duration).timeout.connect(remove_status.bind(burning_preload))
			return burning_preload
		Global.STATUS_TYPE.BLEEDING:
			get_tree().create_timer(bleeding_preload.duration).timeout.connect(remove_status.bind(bleeding_preload))
			reduce_resistances(.15, bleeding_preload.duration)
			return bleeding_preload
		Global.STATUS_TYPE.POISONED:
			get_tree().create_timer(poisoned_preload.duration).timeout.connect(remove_status.bind(poisoned_preload))
			return poisoned_preload
		Global.STATUS_TYPE.SLEEP:
			get_tree().create_timer(sleep_preload.duration).timeout.connect(remove_status.bind(sleep_preload))
			return sleep_preload
		_:
			return burning_preload

func status_decay():
	if decay_tween:
		decay_tween.kill()

	decay_tween = create_tween()
	decay_tween.set_parallel()
	
	for i in available_statuses:
		var start_value = available_statuses[i]
		
		decay_tween.tween_method(
			func(v: float)->void:
				statuses_increased.emit(available_statuses)
				available_statuses[i] = v,
			start_value,
			0.0,
			decay_time
		)

func _on_death():
	for i in statuses.values():
		remove_status(i)
	for i in get_children():
		i.queue_free()
		
func reduce_resistances(amount: float, duration: float):
	var stored_resists: Dictionary = hurtbox.damage_resistances.duplicate()
	for i in hurtbox.damage_resistances:
		hurtbox.damage_resistances[i] *= (1.0 - amount)
	await get_tree().create_timer(duration).timeout
	for i in stored_resists:
		hurtbox.damage_resistances[i] = stored_resists[i]
