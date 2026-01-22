class_name status_effect_component
extends GPUParticles3D

@export var available_statuses: Dictionary[Global.STATUS_TYPE, float]
@export var hurtbox: hurtbox_component
@export var statuses: Dictionary[Global.STATUS_TYPE, status_effect]
@export var mesh_to_affect: MeshInstance3D
@export var health_component: HealthComponent

var resistance_timer = Timer.new()
var times_applied: int = 1
var status_size: int
var burning_preload = preload("res://status_effects/burning.tres")
var bleeding_preload = preload("res://status_effects/bleeding.tres")
var poisoned_preload = preload("res://status_effects/poisoned.tres")
var sleep_preload = preload("res://status_effects/sleep.tres")

var child_damage_component
var status_buildup_progress_clamp: float

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
					emitting = true
					statuses[status_type] = check_status_type(status_type)
					_apply_statuses(statuses.values())
					times_applied += 1

func _apply_statuses(effects: Array[status_effect]):
	if effects.size() == 0:
		return
		
	if effects.size() > 1:
		for i in effects:
			var additional_particles = GPUParticles3D.new()
			add_child(additional_particles)
			additional_particles.emitting = true
			additional_particles.process_material = self.process_material.duplicate()
			additional_particles.draw_pass_1 = i.status_effect_mesh
			additional_particles.process_material["gravity"].y = i.gravity
			if i.turbulence:
				additional_particles.process_material["turbulence_enabled"] = true
			if i.damage_component_scene != null:
				child_damage_component = i.damage_component_scene.instantiate()
				add_child(child_damage_component)
				child_damage_component.connect("increment_shader",increment_shader)
			if i.is_animated:
				additional_particles.process_material["anim_speed"] = 1
			if i.shader_buildup_max > 0:
				status_buildup_progress_clamp = i.shader_buildup_max
	else:
		for i in effects:
			self.draw_pass_1 = i.status_effect_mesh
			self.process_material["gravity"].y = i.gravity
			if mesh_to_affect != null:
				if i.affected_target_next_pass != null:
					if mesh_to_affect.get_surface_override_material(0).next_pass == null:
						mesh_to_affect.get_surface_override_material(0).next_pass = i.affected_target_next_pass.duplicate()
			if i.turbulence:
				self.process_material["turbulence_enabled"] = true
			if i.damage_component_scene != null:
				child_damage_component = i.damage_component_scene.instantiate()
				add_child(child_damage_component)
				if !health_component.is_connected("health_changed", increment_shader):
					health_component.connect("health_changed", increment_shader)
			if i.is_animated:
				self.process_material["anim_speed_min"] = 1.0
			if i.shader_buildup_max > 0:
				status_buildup_progress_clamp = i.shader_buildup_max


func check_status_type(status: Global.STATUS_TYPE) -> status_effect:
	match status:
		Global.STATUS_TYPE.BURNING:
			get_tree().create_timer(10).timeout.connect(remove_status.bind(burning_preload))
			return burning_preload
		Global.STATUS_TYPE.BLEEDING:
			get_tree().create_timer(10).timeout.connect(remove_status.bind(bleeding_preload))
			return bleeding_preload
		Global.STATUS_TYPE.POISONED:
			get_tree().create_timer(10).timeout.connect(remove_status.bind(poisoned_preload))
			return poisoned_preload
		Global.STATUS_TYPE.SLEEP:
			get_tree().create_timer(10).timeout.connect(remove_status.bind(sleep_preload))
			return sleep_preload
		_:
			return burning_preload

func remove_status(effect: status_effect):
	if statuses.has(effect.effect_type): 
		statuses.erase(effect.effect_type)
		if is_instance_valid(child_damage_component):
			child_damage_component.queue_free()
		emitting = false
		available_statuses[effect.effect_type] = 0
		var material = mesh_to_affect.get_surface_override_material(0).next_pass
		var tween = get_tree().create_tween()
		tween.tween_property(material, "shader_parameter/progress",0,1)
	

func increment_shader(amount: float, new_value: float):
	if health_component != null:
		if new_value <= 0:
			var material = mesh_to_affect.get_surface_override_material(0).next_pass
			var tween = get_tree().create_tween()
			tween.tween_property(material, "shader_parameter/progress",clampf(material["shader_parameter/progress"]+1,0,status_buildup_progress_clamp),.5)
		else:
			var ratio = 1-(health_component.current_health/health_component.max_health)
			var material = mesh_to_affect.get_surface_override_material(0).next_pass
			var tween = get_tree().create_tween()
			tween.tween_property(material, "shader_parameter/progress",clampf(material["shader_parameter/progress"]+ratio,0,status_buildup_progress_clamp),.5)

func _on_death():
	for i in statuses.values():
		remove_status(i)
