class_name status_effect_component
extends Node3D

signal status_activated(effects: Array[status_effect])
signal status_removed(effect: status_effect)

@export var available_statuses: Dictionary[Global.STATUS_TYPE, float]
@export var hurtbox: hurtbox_component
@export var statuses: Dictionary[Global.STATUS_TYPE, status_effect]
@export var mesh_to_affect: MeshInstance3D
@export var health_component: HealthComponent
@export var bone_health_component_array: Array[BoneHealthComponent]

var resistance_timer = Timer.new()
var decay_timer = Timer.new()
var times_applied: int = 1
var status_size: int

var burning_preload = preload("res://status_effects/burning/burning.tres")
var bleeding_preload = preload("res://status_effects/bleeding/bleeding.tres")
var poisoned_preload = preload("res://status_effects/poisoned/poisoned.tres")
var sleep_preload = preload("res://status_effects/sleep/sleep.tres")
var leprosy_preload = preload("res://status_effects/leprosy/leprosy.tres")
var paralyze_preload

var child_damage_component
var status_buildup_progress_clamp: float
var decay_tween: Tween

func _ready() -> void:
	if hurtbox != null:
		if !hurtbox.is_connected("apply_statuses", _on_status_increment):
			hurtbox.connect("apply_statuses", _on_status_increment)
	if health_component != null:
		if !health_component.is_connected("died", _on_death):
			health_component.connect("died", _on_death)
	resistance_timer = Timer.new()
	add_child(resistance_timer)
	resistance_timer.one_shot = true
	resistance_timer.timeout.connect(func(): times_applied = 1)

func _on_status_increment(status_type: Global.STATUS_TYPE, application_amount: float):
	if !available_statuses.keys().has(status_type):
		return
	else:
		if available_statuses[status_type] < 1:
			available_statuses[status_type] += (application_amount/times_applied)
			resistance_timer.wait_time = 10 * times_applied
			resistance_timer.start()
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
			reduce_resistances(.15, bleeding_preload.duration)
			get_tree().create_timer(bleeding_preload.duration).timeout.connect(remove_status.bind(bleeding_preload))
			return bleeding_preload
		Global.STATUS_TYPE.POISONED:
			get_tree().create_timer(poisoned_preload.duration).timeout.connect(remove_status.bind(poisoned_preload))
			return poisoned_preload
		Global.STATUS_TYPE.SLEEP:
			owner.sleep(sleep_preload.duration)
			get_tree().create_timer(sleep_preload.duration).timeout.connect(remove_status.bind(sleep_preload))
			return sleep_preload
		Global.STATUS_TYPE.LEPROSY:
			remove_limb(leprosy_preload.duration)
			get_tree().create_timer(leprosy_preload.duration).timeout.connect(remove_status.bind(leprosy_preload))
			return leprosy_preload
		_:
			return burning_preload

func remove_status(effect: status_effect):
	if statuses.has(effect.effect_type):
		status_removed.emit(effect)
		statuses.erase(effect.effect_type)
		if is_instance_valid(child_damage_component):
			child_damage_component.queue_free()
		available_statuses[effect.effect_type] = 0
		if mesh_to_affect:
			var material = mesh_to_affect.material_overlay
			var tween = get_tree().create_tween()
			tween.set_parallel()
			tween.tween_property(material, "shader_parameter/progress", 0, 1)
			tween.tween_property(material, "shader_parameter/wave_amplitude", 0, 1)
			tween.tween_property(material, "shader_parameter/char_opacity", 0, 1)
	
func status_decay():
	if decay_tween:
		decay_tween.kill()
	
	decay_tween = create_tween()
	
	decay_tween.tween_method(
		func(v: float)->void:
			for i in available_statuses:
				available_statuses[i] = lerp(available_statuses[i] as float, 0.0, v),
		0.0,
		1.0,
		2.0
	)

func reduce_resistances(amount: float, duration: float):
	var stored_resists: Dictionary = hurtbox.damage_resistances.duplicate()
	for i in hurtbox.damage_resistances:
		hurtbox.damage_resistances[i] *= (1.0 - amount)
	await get_tree().create_timer(duration).timeout
	for i in stored_resists:
		hurtbox.damage_resistances[i] = stored_resists[i]

func remove_limb(duration:float):
	var idx = randi_range(0, bone_health_component_array.size()-1)
	var random_limb = bone_health_component_array[idx]
	var random_time = randf_range(5, duration)
	await get_tree().create_timer(random_time).timeout
	random_limb.sever_bones()

func _on_death():
	for i in statuses.values():
		remove_status(i)
