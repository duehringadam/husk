class_name SingleDamageComponent
extends DamageComponent

@export var blood_vfx: Node3D

var local_shape_idx: int

func _physics_process(delta: float) -> void:
	if monitoring:
		for other in get_overlapping_areas():
			if !hits.has(other.owner):
				if other is hurtbox_component:
					if other.owner is npc:
						var damage = get_damage(other)
						for i in damage:
							if i > 0:
								var actual = other.take_damage(damage_types, status_types, stance_damage_value, self)
								emit_signal("damage_dealt", damage_types, actual, stance_damage_value, other)
								if hit_sound:
									hit_sound.pitch_scale = randf_range(0.9,1.2)
									hit_sound.play()
						
						var damage_collider: CollisionShape3D = get_child(local_shape_idx)
						damage_collider.disabled = true
						if blood_vfx:
							blood_vfx.bleed()
							blood_vfx.global_position = damage_collider.global_position
						hits.append(other.owner)


func _on_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, _local_shape_index: int) -> void:
	if area is hurtbox_component:
		local_shape_idx = _local_shape_index
