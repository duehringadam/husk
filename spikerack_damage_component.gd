class_name SingleDamageComponent
extends DamageComponent

func _physics_process(delta: float) -> void:
	if monitoring:
		for other in get_overlapping_areas():
			if !hits.has(other.owner):
				if other is hurtbox_component:
						var damage = get_damage(other)
						for i in damage:
							if i > 0:
								var actual = other.take_damage(damage_types, status_types, stance_damage_value, self)
								emit_signal("damage_dealt", damage_types, actual, stance_damage_value, other)
								if hit_sound:
									hit_sound.pitch_scale = randf_range(0.9,1.2)
									hit_sound.play()
						self.monitorable = false
						self.monitoring = false
