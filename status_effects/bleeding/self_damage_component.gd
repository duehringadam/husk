class_name SelfDamageComponent
extends DamageComponent

func _physics_process(_delta: float) -> void:
	if timer.time_left > 0: return
	if monitoring:
		for other in get_overlapping_areas():
			if !hits.has(other.owner):
				if other is hurtbox_component:
					if other.owner == self.owner:
						hits.append(other.owner)
						var damage = get_damage(other)
						get_tree().create_timer(damage_interval).timeout.connect(func(): hits.clear())
						for i in damage:
							if i > 0:
								var actual = other.take_damage(damage_types, status_types, stance_damage_value, self, slow_amount)
								emit_signal("damage_dealt", damage_types, actual, stance_damage_value, other, slow_amount)
								invulnerability(damage_interval)
								if hit_sound:
									hit_sound.pitch_scale = randf_range(0.9,1.2)
									hit_sound.play()
