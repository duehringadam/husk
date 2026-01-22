extends hurtbox_component

@export var player_camera: Camera3D
@export var viewport_camera: Camera3D

var is_blocking: bool = false

func _ready():
	SignalBus.connect("is_blocking", _update_blocking)
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	SignalBus.connect("player_immune",invulnerability)

func _update_blocking(value:bool):
	is_blocking = value

func take_damage(damage_types: Dictionary[DamageTypes.DAMAGE_TYPES, float], status_types: Dictionary[Global.STATUS_TYPE, float], stance_damage: float, source: DamageComponent):
	if timer.time_left > 0: return 0
	
	if is_blocking && is_facing(source): 
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
	var sum := 0.0
	for i in damage_types:
		var actual = modify_damage(i,damage_types[i],source)
		emit_signal("damage_taken", actual, source, Vector3.ZERO)
		sum += actual
	if hit_sound != null:
		AudioManager.play_sound(hit_sound,self.global_position,-10.0)
	health_component.modify_health(-sum)
	return sum
	

func is_facing(source: DamageComponent) -> bool:
	var player_forward = -Global.player.camera.global_transform.basis.z 
	var target_direction = (source.owner.global_transform.origin - Global.player.camera.global_transform.origin).normalized()
	var dot_product = player_forward.dot(target_direction)
	var angle_to_target = acos(dot_product)
	if angle_to_target < deg_to_rad(60):
		return true
	return false
