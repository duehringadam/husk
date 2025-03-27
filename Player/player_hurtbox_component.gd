extends hurtbox_component

@export var player_camera: Camera3D

func take_damage(amount: float, source: DamageComponent):
	if timer.time_left > 0: return 0
	
	if Global.player.blocking && is_facing(source): 
		player_camera.apply_shake()
		Global.player.offhand.offhand.block()
		invulnerability(invulnerability_duration)
		return 0 
	# invulnerability on damage
	AudioManager.play_sound(load("res://sfx/hit-rock-03-266305.mp3"),global_position,-10)
	invulnerability(invulnerability_duration)
	# take damage
	var actual = reduce_damage(amount, source)
	emit_signal("damage_taken", amount, actual, source)
	health_component.modify_health(-actual)
	return actual
	

func is_facing(source: DamageComponent):
	var block_dir = sign(Global.player.offhand.offhand.global_position.x - global_position.x)
	var hit_dir = sign(global_position.x - source.global_position.x)
	return block_dir != hit_dir
