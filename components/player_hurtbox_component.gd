extends hurtbox_component

signal blocked_attack
signal stance_broken

@export var player_camera: Camera3D
@export var stamina_component: StaminaComponent

func _ready():
	SignalBus.connect("is_blocking", _update_blocking)
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	SignalBus.connect("player_immune",invulnerability)

func _update_damage_resistances(resists: Dictionary[DamageTypes.DAMAGE_TYPES, float]):
	damage_resistances = resists
	SignalBus.emit_signal("player_resists_changed", resists)

func _update_status_resistances(resists: Dictionary[Global.STATUS_TYPE, float]):
	status_resistances = resists
	SignalBus.emit_signal("player_status_resists_changed", status_resistances)

func _update_blocking(value:bool):
	is_blocking = value

func take_damage(damage_types: Dictionary[DamageTypes.DAMAGE_TYPES, float], status_types: Dictionary[Global.STATUS_TYPE, float], stance_damage: float, source: DamageComponent, slow_amount: float):
	if timer.time_left > 0: return 0
	apply_slow.emit(slow_amount)
	if is_blocking && is_facing(source): 
		for i in damage_types:
			player_camera.apply_shake(0.025)
			var sum:= 0.0
			var actual = modify_damage(i,damage_types[i],source)
			sum += actual
			stamina_component.modify_stamina(-sum)
			
			if stamina_component.current_stamina <= 0:
				stance_broken.emit()
			emit_signal("blocked_attack")
		return 0 
	# invulnerability on damage
	
	if hit_sound != null:
		AudioManager.play_sound(hit_sound,global_position,-10)
	invulnerability(invulnerability_duration)
	# take damage
	var sum := 0.0
	for i in damage_types:
		if status_types.size() != 0:
				apply_status(status_types)
		var actual = modify_damage(i,damage_types[i],source)
		emit_signal("damage_taken", actual, source, Vector3.ZERO)
		sum += actual
	if hit_sound != null:
		AudioManager.play_sound(hit_sound,self.global_position,-10.0)
	health_component.modify_health(-sum)
	return sum
	

func is_facing(source: DamageComponent) -> bool:
	if source.source == Global.player: 
		return false
	var player_forward = -Global.player.camera.global_transform.basis.z 
	var target_direction = (source.source.global_transform.origin - Global.player.camera.global_transform.origin).normalized()
	var dot_product = player_forward.dot(target_direction)
	var angle_to_target = acos(dot_product)
	if angle_to_target <= deg_to_rad(75):
		return true
	return false


func _on_player_hands_equip_item(item_equipped: item) -> void:
	if item_equipped is not armor:
		return
		
	for i in item_equipped.damage_resistances:
		damage_resistances[i] += item_equipped.damage_resistances[i]
		_update_damage_resistances(damage_resistances)
	for i in item_equipped.status_resistances:
		status_resistances[i] += item_equipped.status_resistances[i]
		_update_status_resistances(status_resistances)

func _on_player_hands_unequip_item(item_unequipped: item) -> void:
	if item_unequipped is not armor:
		return
		
	for i in item_unequipped.damage_resistances:
		damage_resistances[i] -= item_unequipped.damage_resistances[i]
		_update_damage_resistances(damage_resistances)
	for i in item_unequipped.status_resistances:
		status_resistances[i] -= item_unequipped.status_resistances[i]
		_update_status_resistances(status_resistances)
