extends DamageComponent


func _physics_process(delta: float) -> void:
	if monitoring:
		for other in get_overlapping_areas():
			if !hits.has(other.owner):
				if other is hurtbox_component:
					hits.append(other.owner)
					var damage = get_damage(other)
					get_tree().create_timer(1).timeout.connect(func(): hits.clear())
					for i in damage:
						if i > 0:
							var actual = other.take_damage(damage_types, status_types, self)
							emit_signal("damage_dealt", damage_types, actual, other)
							AudioManager.play_sound(hit_sound, self.global_position, 0.0)
