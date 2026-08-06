extends DamageComponent

@export var kick_strength: float

## Override this to customize damage behavior (scale with velocity, etc)
func get_damage(target: hurtbox_component):
	return damage_types.values()

#func _ready() -> void:
	#connect("area_entered", self._physics_process)
		
func _physics_process(delta: float) -> void:
	if monitoring:
		for other in get_overlapping_areas():
			if !hits.has(other.owner):
				if other is hurtbox_component:
					if other.get_parent() is Pickable:
						var root = other.get_parent()
						root.apply_central_impulse(-Global.player.camera.global_transform.basis.z.normalized() * root.mass * kick_strength)
					hits.append(other.owner)
					var damage = get_damage(other)
					get_tree().create_timer(1).timeout.connect(func(): hits.clear())
					for i in damage:
						if i > 0:
							var actual = other.take_damage(damage_types, status_types, stance_damage_value, self)
							emit_signal("damage_dealt", damage_types, actual, stance_damage_value, other)
							if hit_sound:
								hit_sound.play()
