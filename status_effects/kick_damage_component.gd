extends DamageComponent

## Override this to customize damage behavior (scale with velocity, etc)
func get_damage(target: hurtbox_component):
	return damage_types.values()

#func _ready() -> void:
	#connect("area_entered", self._physics_process)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("kick"):
		monitoring = true
		monitorable = true
		get_tree().create_timer(.5).timeout.connect(func():monitoring = false;monitorable = false)

func _physics_process(delta: float) -> void:
	if monitoring:
		for other in get_overlapping_areas():
			if !hits.has(other.owner):
				if other is hurtbox_component:
					if other.get_parent() is throwable_object:
						var root = other.get_parent()
						root.throw(-Global.player.camera.global_transform.basis.z.normalized(), 25)
					if other.get_parent() is NPC:
						var root = other.get_parent()
						root.fall(-Global.player.camera.global_transform.basis.z.normalized() * 25)
					hits.append(other.owner)
					var damage = get_damage(other)
					get_tree().create_timer(1).timeout.connect(func(): hits.clear())
					for i in damage:
						if i > 0:
							var actual = other.take_damage(damage_types, status_types, self)
							emit_signal("damage_dealt", damage_types, actual, other)
							AudioManager.play_sound(hit_sound, self.global_position, 0.0)
