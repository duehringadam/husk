extends humanoid_npc

@onready var vocalizations: AudioStreamPlayer3D = $vocalizations
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


func _physics_process(delta: float) -> void:
	direction = navigation_agent.get_next_path_position() - global_transform.origin
	direction = direction.normalized()
	velocity = velocity.lerp(direction * SPEED, delta * 10)
	
	if !is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity")*delta
	_push_rigid_bodies()
	move_and_slide()

func _update_blocking(value: bool):
	if value && left_arm && has_shield:
		is_blocking = value
		hurtbox.is_blocking = value
		activate_main_offhand_weapon(true)
		animation_tree.set("parameters/walkBlendTree/Transition/transition_request", "walk with shield")
		animation_tree.set("parameters/runBlendTree/Transition/transition_request", "run with shield")
	elif !value:
		is_blocking = value
		hurtbox.is_blocking = value
		activate_main_offhand_weapon(false)
		animation_tree.set("parameters/walkBlendTree/Transition/transition_request", "walk")
		animation_tree.set("parameters/runBlendTree/Transition/transition_request", "run")

func _on_health_component_died() -> void:
	fall()
	state_chart.send_event("dead")
	collision_layer = 0
	
	
func head_lost(value: bool)-> void:
	if !is_infested:
		if !value:
			health_component.modify_health(-9999)
			
func fall():
	state_chart.send_event("knocked_down")
	physical_bone_simulator.physical_bones_start_simulation()
	SPEED = 0
	
func _on_stance_component_stance_changed(amount: float, new_value: float, source: DamageComponent) -> void:
	if stance_component:
		if new_value <= 0:
			if !is_facing(source):
				if has_shield:
					is_blocking = false
				var animation_state_tree_root = animation_tree.get("tree_root")
				var knocked_back_node = animation_state_tree_root.get_node("KnockedBack")
				knocked_back_node.animation = "Hit_B_2_InPlace"
			else:
				if has_shield:
					is_blocking = false
				var animation_state_tree_root = animation_tree.get("tree_root")
				var knocked_back_node = animation_state_tree_root.get_node("KnockedBack")
				knocked_back_node.animation = "Hit_F_1_InPlace"
			if source.source is Player:
				state_chart.set_expression_property("knockback_source", source.source)
				state_chart.send_event("knocked_back")
			else:
				state_chart.set_expression_property("knockback_source", source)
				state_chart.send_event("knocked_back")
		if abs(amount) >= stance_component.max_stance:
			if has_shield:
				is_blocking = false
			if source.source is Player:
				state_chart.set_expression_property("knockback_source", source.source)
				state_chart.send_event("knocked_back")
			else:
				state_chart.set_expression_property("knockback_source", source)
				state_chart.send_event("knocked_back")


func is_facing(source: DamageComponent) -> bool:
	var self_forward = -self.global_transform.basis.z 
	var target_direction = (source.global_transform.origin - self.global_transform.origin).normalized()
	var dot_product = self_forward.dot(target_direction)
	var angle_to_target = acos(dot_product)
	if angle_to_target < deg_to_rad(90):
		return true
	return false


func _on_hurtbox_component_damage_taken(actual: float, source: DamageComponent, hit_dir: Vector3) -> void:
	if !vocalizations.playing && health_component.current_health > 0:
		vocalizations.play()
		
	var animation_state_tree_root = animation_tree.get("tree_root")
	
	var walk_hit_node = animation_state_tree_root.get_node("walkBlendTree")
	var walk_blend_tree_node = walk_hit_node.get_node("flinch")
	
	var idle_hit_node = animation_state_tree_root.get_node("idleHitBlendTree")
	var idle_blend_tree_node = idle_hit_node.get_node("flinch")
	
	var run_hit_node = animation_state_tree_root.get_node("runBlendTree")
	var run_hit_blend_tree_node = run_hit_node.get_node("flinch")
	
	if !is_facing(source):
		walk_blend_tree_node.animation = "Hit_B_3_InPlace"
		idle_blend_tree_node.animation = "Hit_B_3_InPlace"
		run_hit_blend_tree_node.animation = "Hit_B_3_InPlace"
	else:
		walk_blend_tree_node.animation = "Hit_F_2_InPlace"
		idle_blend_tree_node.animation = "Hit_F_2_InPlace"
		run_hit_blend_tree_node.animation = "Hit_F_2_InPlace"
	if source.source != null:
		target = source.source
	var current_state = animation_tree.get("parameters/playback").get_current_node()

	if current_state == "walkBlendTree":
		animation_tree.set("parameters/walkBlendTree/walkHit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		animation_tree.set("parameters/runBlendTree/runHit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
		if has_shield:
			animation_tree.set("parameters/walkBlendTree/shieldWalkHit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			animation_tree.set("parameters/runBlendTree/shieldWalkHit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	if current_state == "runBlendTree":
		animation_tree.set("parameters/runBlendTree/runHit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		animation_tree.set("parameters/walkBlendTree/walkHit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
		if has_shield:
			animation_tree.set("parameters/runBlendTree/shieldWalkHit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			animation_tree.set("parameters/walkBlendTree/shieldWalkHit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

func leg_lost(value: bool)-> void:
	if !value:
		fall()
		_on_health_component_died()

func _on_bone_health_component_bones_severed(bones: Array) -> void:
	for i in bones:
		if i.to_lower().contains("rightupperarm"):
			right_arm = false
		if i.to_lower().contains("leftupperarm"):
			left_arm = false
		if i.to_lower().contains("leg"):
			leg_attached = false
		if i.to_lower().contains("head"):
			head_attached = false


func _on_status_effect_component_status_activated(effects: Array[status_effect]) -> void:
	for i in effects:
		if i.effect_type == Global.STATUS_TYPE.BURNING:
			state_chart.set_expression_property("death_special", true)
			await get_tree().create_timer(5).timeout
			state_chart.send_event("dead")
			SPEED = 0


func _on_hurtbox_component_damage_blocked() -> void:
	if offhand.get_child_count() > 0:
		if offhand.get_child(0) is npc_shield:
			var current_state = animation_tree.get("parameters/playback").get_current_node()
			if current_state == "walkBlendTree":
				animation_tree.set("parameters/walkBlendTree/shieldWalkHit/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			if current_state == "runBlendTree":
				animation_tree.set("parameters/runBlendTree/shieldWalkHit/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func sleep(duration: float):
	state_chart.set_expression_property("death_special", true)
	state_chart.send_event("sleep")
	%sleepTimer.wait_time = duration
	%sleepTimer.start()
