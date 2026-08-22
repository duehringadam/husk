extends npc

var locked_in: bool = false

func _ready() -> void:
	state_chart.set_expression_property("has_howled", false)
	
func _physics_process(delta: float) -> void:
	if !locked_in:
			direction = navigation_agent.get_next_path_position() - global_transform.origin
			direction = direction.normalized()
		
	SPEED = (animation_tree.get_root_motion_position() / delta).length()
	velocity = SPEED * direction
	if !is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity")
	move_and_slide()

func _on_stance_component_stance_changed(amount: float, new_value: float, source: DamageComponent) -> void:
	if stance_component:
		if abs(amount) >= stance_component.max_stance/2:
			if !is_facing(source):
				var animation_state_tree_root = animation_tree.get("tree_root")
				var knocked_back_node = animation_state_tree_root.get_node("KnockedBack")
				knocked_back_node.animation = "Hit_B_2_InPlace"
			else:
				var animation_state_tree_root = animation_tree.get("tree_root")
				var knocked_back_node = animation_state_tree_root.get_node("KnockedBack")
				knocked_back_node.animation = "Hit_F_1_InPlace"
			state_chart.set_expression_property("knockback_source", source)
			state_chart.send_event("knocked_back")
		if abs(amount) >= stance_component.max_stance:
			state_chart.set_expression_property("knockback_source", source)
			state_chart.send_event("knocked_down")

func is_facing(source: DamageComponent) -> bool:
	var self_forward = -self.global_transform.basis.z 
	var target_direction = (source.global_transform.origin - self.global_transform.origin).normalized()
	var dot_product = self_forward.dot(target_direction)
	var angle_to_target = acos(dot_product)
	if angle_to_target < deg_to_rad(90):
		return true
	return false
