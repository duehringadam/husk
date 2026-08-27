extends npc

@onready var patrol: Node = $StateChart/CompoundState/patrol/patroling
@onready var body: Node3D = $SK_Aranocodus

@export var is_embedded: bool = false
@export var sample_area: float = 0.5

var timer: float = 0.0
var search_position : Vector3
var first_aggro: bool = true
var locked_in: bool = false

func _ready() -> void:
	if is_embedded:
		animation_tree.active = false
		state_chart.call_deferred("send_event", "embed")
		self.visible = false

func _physics_process(delta: float) -> void:
	#var curr_rot = (animation_tree.get_root_motion_rotation_accumulator().inverse() * get_quaternion())
	#var root_rotation = animation_tree.get_root_motion_rotation()
	if !locked_in:
		direction = navigation_agent.get_next_path_position() - global_transform.origin
		direction = direction.normalized()
	
	SPEED = (animation_tree.get_root_motion_position() / delta).length()
	velocity = SPEED * direction
	if !is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity")
	move_and_slide()
	
	var space_state = get_world_3d().direct_space_state
	# use global coordinates, not local to node
	var result_transformation: Transform3D = global_transform
	for i in range(2):
		for j in range(2):
			var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(global_position - Vector3(1-i, 0, 1-j), global_position - Vector3(1-i, 0.2, 1-j)))
			if result:
				result_transformation = align_with_y(result_transformation, result.normal)
	
	if result_transformation != global_transform:
		body.global_transform = lerp(body.global_transform, result_transformation, delta * 5.0)
	else:
		body.global_transform = lerp(body.global_transform, result_transformation, delta*  0.5)

func align_with_y(xform: Transform3D, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform


func _on_vision_area_max_aggro(aggro_amount: float, aggro_position: Node3D) -> void:
	target = Global.player
	if !is_embedded:
		$trill.pitch_scale = randf_range(0.8,1.2)
		$trill.play()


func _on_damage_component_damage_dealt(types: Dictionary, actual: float, stance_damage: float, target: hurtbox_component) -> void:
	pass
	
func _on_health_component_died() -> void:
	fall()
	state_chart.send_event("dead")
	SignalBus.emit_signal("enemy_currency_dropped", currency_dropped)
	
func fall()-> void:
	physical_bone_simulator.physical_bones_start_simulation()
	collision_layer = 0


func _on_stance_component_stance_changed(amount: float, new_value: float, source: DamageComponent) -> void:
	if stance_component:
		if abs(amount) >= stance_component.max_stance/2:
			state_chart.set_expression_property("knockback_source", source)
			state_chart.send_event("knocked_back")
		if abs(amount) >= stance_component.max_stance:
			state_chart.set_expression_property("knockback_source", source)
			state_chart.send_event("knocked_down")


func _on_hurtbox_component_damage_taken(actual: float, source: DamageComponent, hit_dir: Vector3) -> void:
	animation_tree.set("parameters/conditions/hit", true)
	await get_tree().create_timer(.25).timeout
	animation_tree.set("parameters/conditions/hit", false)


func _on_approach_detector_rapid_approach_detected() -> void:
	state_chart.send_event("chase")


func sleep(duration: float):
	state_chart.send_event("sleep")
	%sleepTimer.wait_time = duration
	%sleepTimer.start()
