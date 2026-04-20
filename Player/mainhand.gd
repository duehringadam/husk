extends Node3D

@export var weapon: item: set = _set_item
@export var offhand: Node3D
@export var animation_state_machine: AnimationNodeStateMachine
@export var bone_attachment: BoneAttachment3D

@onready var animation_tree: AnimationTree = $ghoul_arms_new/AnimationTree
@onready var skeleton: Skeleton3D = $ghoul_arms_new/Armature/Skeleton3D
@onready var attack_timer: Timer = $attackTimer
@onready var hands: MeshInstance3D = $ghoul_arms_new/Armature/Skeleton3D/hands
@onready var stab_damage: DamageComponent = $stabDamage
@onready var state_chart: StateChart = $ghoul_arms_new/StateChart
@onready var stab_collision: CollisionShape3D = $stabDamage/CollisionShape3D
@onready var damage_scaling: damage_scaling_component = $damage_scaling_component

@export var ray_length :float = 2
@export var ray_count: int = 16
@export_range(0,360) var spread_angle: float = 30 # Spread 30 degrees

var space_state
var attack_dir
var can_attack = true
var cam_basis: Basis
var cam_pos : Vector3
var camera: Camera3D
var hits: Array
var tween: Tween
var result
var query
var damage_component: DamageComponent
func _ready() -> void:
	if bone_attachment.get_child_count() > 0:
		animation_tree.active = true

func _set_item(new_item: item):
	if new_item != null:
		weapon = new_item
		var item_add = new_item.item_scene.instantiate()
		if is_instance_valid(offhand):
			if new_item.two_handed:
				offhand.unequip()
				var left_arm_idx = skeleton.find_bone("segment.L")
				skeleton.set_bone_pose_scale(left_arm_idx, (Vector3(1,1,1)))
			else:
				var left_arm_idx = skeleton.find_bone("segment.L")
				skeleton.set_bone_pose_scale(left_arm_idx, (Vector3(0.01,0.01,0.01)))
		if bone_attachment.get_child_count() != 0:
			unequip()
		state_chart.send_event("idle")
		item_add.position = weapon.position
		item_add.rotation_degrees = weapon.rotation
		animation_state_machine = weapon.animation_state_machine
		animation_tree.tree_root = animation_state_machine
		animation_tree.active = false
		await get_tree().create_timer(.1).timeout
		animation_tree.active = true
		bone_attachment.add_child(item_add)
		damage_component = bone_attachment.get_child(0).damage_component
		bone_attachment.get_child(0).damage_component.damage_types = new_item.item_stats.damage_types
		stab_damage.damage_types = new_item.item_stats.damage_types
		stab_damage.status_types = item_add.damage_component.status_types
		stab_damage.stance_damage_value = new_item.item_stats.stance_damage
		stab_damage.hit_sound = item_add.damage_component.hit_sound
		ray_length = new_item.item_stats.range
		stab_collision.shape.height = new_item.item_stats.range
		damage_scaling.damage_component = damage_component
		damage_scaling.stored_damage_values = new_item.item_stats.damage_types.values()
		damage_scaling.stored_stance_damage = new_item.item_stats.stance_damage
		
		

func unequip():
	state_chart.send_event("lower")
	weapon = null
	for i in bone_attachment.get_children():
		i.queue_free()
	


func _on_bloodtimer_timeout() -> void:
	bone_attachment.get_child(0).blood_drip.emitting = false
	remove_blood()

func _on_damage_dealt(target: hurtbox_component) -> void:
	Global.player.camera.apply_shake(0.04)
	if !target.can_bleed:
		return
		
	var weapon_mesh_shader = bone_attachment.get_child(0).weapon_mesh.get_active_material(0)
	var hand_mesh_shader = hands.get_active_material(0)
	weapon_mesh_shader.next_pass["shader_parameter/progress"] = clampf(weapon_mesh_shader.next_pass["shader_parameter/progress"]+.05,0,.5)
	hand_mesh_shader.next_pass["shader_parameter/progress"] = clampf(hand_mesh_shader.next_pass["shader_parameter/progress"]+.05,0,.5)
	if weapon_mesh_shader.next_pass["shader_parameter/progress"] >= .4 && bone_attachment.get_child(0).blood_drip != null:
		bone_attachment.get_child(0).blood_drip.emitting = true
		bone_attachment.get_child(0).bloodtimer.start()
	else:
		bone_attachment.get_child(0).blood_drip.emitting = false

func remove_blood():
	bone_attachment.get_child(0).blood_drip.emitting = false
	var weapon_mesh_shader = bone_attachment.get_child(0).weapon_mesh.get_active_material(0)
	var hand_mesh_shader = hands.get_active_material(0)
	tween = get_tree().create_tween()
	tween.tween_property(weapon_mesh_shader.next_pass,"shader_parameter/progress",0,60)
	tween.set_parallel()
	tween.tween_property(hand_mesh_shader.next_pass,"shader_parameter/progress",0,60)
	
	
func _process(delta: float) -> void:
	attack_dir = Global.player.attack_dir
	

func _physics_process(delta: float) -> void:
	space_state = get_world_3d().direct_space_state
	camera = get_viewport().get_camera_3d()
	cam_pos = camera.global_position
	cam_basis = camera.global_transform.basis
	if query != null:
		result = space_state.intersect_ray(query)
	

func stab():
	stab_damage.monitorable = true
	stab_damage.monitoring = true
	var anim_length = animation_tree.get("parameters/playback").get_current_length()/3
	await get_tree().create_timer(anim_length).timeout
	stab_damage.monitorable = false
	stab_damage.monitoring = false
	
func shoot_arc(direction: Vector2i):
		var anim_length = animation_tree.get("parameters/playback").get_current_length()
		attack_timer.wait_time = (anim_length/5) / ray_count

		if direction.x != 0:
			for i in range(ray_count):
				attack_timer.start()
				# Starting forward vector
				var forward = -cam_basis.z
				var up_axis = cam_basis.y
				
				# Calculate half the spread to center the arc
				var half_spread = spread_angle / 2.0
				var angle_step = spread_angle / (ray_count - 1)
				# Calculate current rotation for this ray
				var current_angle = -half_spread + (i * angle_step)
				
				# Rotate the forward vector around the camera's Y axis (horizontal arc)
				var ray_direction = forward.rotated(up_axis * direction.x, deg_to_rad(-current_angle))
				var target_pos = cam_pos + ray_direction * ray_length
				await attack_timer.timeout
				#DebugDraw3D.draw_ray(cam_pos, ray_direction,ray_length,Color.RED,10)
				_perform_raycast(cam_pos, target_pos)
		if direction.y != 0:
			for i in range(ray_count):
				attack_timer.start()
				# Starting forward vector
				var forward = -cam_basis.z
				var right_axis = cam_basis.x
				
				# Calculate half the spread to center the arc
				var half_spread = spread_angle / 2.0
				var angle_step = spread_angle / (ray_count - 1)
				# Calculate current rotation for this ray
				var current_angle = -half_spread + (i * angle_step)
				
				# Rotate the forward vector around the camera's Y axis (horizontal arc)
				var ray_direction = forward.rotated(right_axis * direction.y, deg_to_rad(-current_angle))
				var target_pos = cam_pos + ray_direction * ray_length
				await attack_timer.timeout
				#DebugDraw3D.draw_ray(cam_pos, ray_direction,ray_length,Color.RED,10)
				_perform_raycast(cam_pos, target_pos)


func _perform_raycast(origin: Vector3, target: Vector3):
	query = PhysicsRayQueryParameters3D.create(origin, target)
	# Optional: exclude the player from hitting themselves
	query.exclude = [self.owner.get_rid()] 
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 14
	
	if result:
		if is_instance_valid(result.collider):
			if result.collider is hurtbox_component && !hits.has(result.collider.owner.get_rid()):
				hits.append(result.collider.owner.get_rid())
				result.collider.take_damage(damage_component.damage_types, damage_component.status_types, damage_component.stance_damage_value, damage_component)
				_on_damage_dealt(result.collider)
				if damage_component.hit_sound:
					damage_component.hit_sound.pitch_scale = randf_range(0.9,1.2)
					damage_component.hit_sound.play()
				# Handle hit logic (e.g., damage) here


func _on_swing_state_exited() -> void:
	hits.clear()


func lower():
	state_chart.send_event("lower")
