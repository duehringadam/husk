extends hurtbox_component

@export var player_camera: Camera3D
@export var viewport_camera: Camera3D

func take_damage(amount: float, source: DamageComponent):
	if timer.time_left > 0: return 0
	
	if Global.player.blocking && is_facing(source): 
		player_camera.apply_shake()
		viewport_camera.apply_shake()
		if Global.player.offhand.get_child_count() > 0:
			Global.player.offhand.get_child(0).block()
		else:
			Global.player.mainhand.get_child(0).block()
		invulnerability(invulnerability_duration)
		return 0 
	# invulnerability on damage
	
	if hit_sound != null:
		AudioManager.play_sound(hit_sound,global_position,-10)
	invulnerability(invulnerability_duration)
	# take damage
	var actual = reduce_damage(amount, source)
	emit_signal("damage_taken", amount, actual, source)
	health_component.modify_health(-actual)
	return actual
	

func is_facing(source: DamageComponent):
	var block_dir = sign(Global.player.offhand.global_position.z - global_position.z)
	var hit_dir = sign(global_position.z - source.global_position.z)
	return block_dir != hit_dir
