class_name PercentageHealthDamageComponent
extends DamageComponent

#floats should be declared in a range of 0.0-1.0, they will be a percentage of targets hp
@export var percent_hp_damage_types: Dictionary[DamageTypes.DAMAGE_TYPES, float]

signal increment_shader(actual: float)

## Override this to customize damage behavior (scale with velocity, etc)
func get_damage(_target: hurtbox_component):
	return damage_types.values()

func get_percentage_damage():
	return percent_hp_damage_types.values()

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if monitoring:
		for other in get_overlapping_areas():
			if !hits.has(other.owner):
				if other is hurtbox_component:
					hits.append(other.owner)
					get_tree().create_timer(damage_interval).timeout.connect(func(): hits.clear())
					var actual_dmg_dict: Dictionary[DamageTypes.DAMAGE_TYPES, float]
					for i in percent_hp_damage_types:
						if percent_hp_damage_types[i] > 0:
							var other_max_health = other.health_component.max_health
							var percent_hp_damage = other_max_health * percent_hp_damage_types[i]
							actual_dmg_dict[i] = percent_hp_damage
							var actual = other.take_damage(actual_dmg_dict, status_types,stance_damage_value, self, slow_amount)
							emit_signal("damage_dealt", damage_types, actual, stance_damage_value, other)
							emit_signal("increment_shader", actual)
							if hit_sound:
								hit_sound.play()
					
