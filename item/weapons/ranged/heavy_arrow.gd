extends PhysicsProjectile

@export var pin_range: float = 5.0
@export var impact_force: float = 60

@onready var smoke: GPUParticles3D = %smoke
@onready var rocks: GPUParticles3D = %rocks
@onready var impact: AudioStreamPlayer3D = $Plane/impact
@onready var trail: GPUTrail3D = $GPUTrail3D
@onready var blood_spout: Node3D = $Plane/VFX_Blood_Constant_A2


var tracking_bone: PhysicalBone3D = null
var wall_target_pos: Vector3
var pin_threshold: float = 1.0
var impact_dir: Vector3

func _ready() -> void:
	set_physics_process(false)
	add_collision_exception_with(Global.player)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() <= 0:
		impact_dir = state.linear_velocity.normalized()
		
	if state.get_contact_count() > 0:
		for i in range(state.get_contact_count()):
			other_hit_point = state.get_contact_collider_position(i)
			local_hit_point = state.get_contact_local_position(i)
			var normal = state.get_contact_local_normal(i)

func _on_body_entered(body: Node) -> void:
	if global_position.distance_to(Global.player.global_position) <= 3:
		Global.player.camera.apply_shake()
	if body is StaticBody3D and tracking_bone == null:
		freeze = true
		self.global_position = other_hit_point
		self.collision_layer = 0
		damage_component.set_deferred("monitorable", false)
		damage_component.set_deferred("monitoring", false)
		projectile_mesh.call_deferred("reparent", body)
		smoke.emitting = true
		rocks.emitting = true
		terrain.play()
		impact.play()
		self.queue_free()
	
	if body is PhysicalBone3D and tracking_bone == null:
		trail.emitting = false
		if body.owner.has_method("fall"):
			body.owner.fall()
		
		blood_spout.reparent(body)
		blood_spout.global_position = body.global_position
		blood_spout.animation_player.play("Init")
		var space_state = get_world_3d().direct_space_state
		var start_pos = other_hit_point
		var end_pos = start_pos + (impact_dir * pin_range)
		
		var query = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
		#DebugDraw3D.draw_arrow_ray(start_pos, impact_dir, pin_range,Color.RED,.5,true,10)

		query.exclude = [body.get_rid()]
		query.collision_mask = 2
		
		var result = space_state.intersect_ray(query)
		
		if is_instance_valid(projectile_mesh):
			projectile_mesh.reparent(body)
		
		if result:
			wall_target_pos = result.position
			#DebugDraw3D.draw_sphere(wall_target_pos,.5,Color.RED,5)
			var distance_to_wall = global_position.distance_to(wall_target_pos)
			var min_force: float = impact_force
			var max_force: float = 200
			var dynamic_force = remap(distance_to_wall, 0.0, pin_range, min_force, max_force)
			dynamic_force = clamp(dynamic_force, min_force, max_force)
				
			body.linear_velocity = (impact_dir * dynamic_force)
			
			tracking_bone = body
			set_physics_process(true)
			body.owner.health_component.modify_health(-9999)
		else:
			body.linear_velocity = (impact_dir * impact_force)
			queue_free()
			
func _physics_process(_delta: float) -> void:
	if not is_instance_valid(tracking_bone):
		queue_free()
		return
		
	var current_dist = tracking_bone.global_position.distance_to(wall_target_pos)
	
	if current_dist <= pin_threshold:
		_execute_wall_pin()
		set_physics_process(false)
		
func _execute_wall_pin() -> void:
	tracking_bone.global_position = wall_target_pos
	tracking_bone.linear_velocity = Vector3.ZERO
	tracking_bone.angular_velocity = Vector3.ZERO
	smoke.emitting = true
	rocks.emitting = true
	terrain.play()
	impact.play()
	var wall_anchor = StaticBody3D.new()
	get_tree().current_scene.add_child(wall_anchor)
	wall_anchor.global_position = wall_target_pos
	
	var pin_joint = Generic6DOFJoint3D.new()
	pin_joint.exclude_nodes_from_collision = true
	get_tree().current_scene.add_child(pin_joint)
	pin_joint.global_position = wall_target_pos
	
	var limit_tolerance: float = 0.05
	pin_joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, limit_tolerance)
	pin_joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, -limit_tolerance)
	pin_joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, limit_tolerance)
	pin_joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, -limit_tolerance)
	pin_joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, limit_tolerance)
	pin_joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, -limit_tolerance)
	
	
	pin_joint.node_b = tracking_bone.get_path()
	pin_joint.node_a = wall_anchor.get_path()
	projectile_mesh.reparent(get_tree().current_scene)
	projectile_mesh.global_position = pin_joint.global_position
	
	queue_free()
