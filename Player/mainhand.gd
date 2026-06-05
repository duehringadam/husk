extends Node3D


@export var weapon: item: set = _set_item
@export var offhand: Node3D
@export var animation_state_machine: AnimationNodeStateMachine
@export var bone_attachment: BoneAttachment3D
@export var left_bone_attachment: BoneAttachment3D

@export var animation_tree: AnimationTree
@export var skeleton: Skeleton3D
@export var hands: MeshInstance3D
@export var state_chart: StateChart


@export var ray_length :float = 2
@export var ray_count: int = 16
@export_range(0,360) var spread_angle: float = 30 # Spread 30 degrees
@export_range(0,360) var stab_spread_angle: float = 30 # Spread 30 degrees

@onready var stab_damage: DamageComponent = $stabDamage
@onready var attack_timer: Timer = $"ghoul_arms2(1)/attackTimer"
@onready var stab_collision: CollisionShape3D = $stabDamage/CollisionShape3D
@onready var damage_scaling: damage_scaling_component = $damage_scaling_component
@onready var arms_base: Node3D = $"ghoul_arms2(1)"

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
	SignalBus.connect("secondary_active", _update_secondary_active)

func _update_secondary_active(value: bool):
	can_attack = !value

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
		
		if new_item.item_left_scene:
			var item_left_add = new_item.item_left_scene.instantiate()
			item_left_add.position = weapon.left_position
			item_left_add.rotation_degrees = weapon.left_rotation
			left_bone_attachment.add_child(item_left_add)
		

func unequip():
	state_chart.send_event("lower")
	weapon = null
	for i in bone_attachment.get_children():
		i.queue_free()
	for i in left_bone_attachment.get_children():
		i.queue_free()


func _on_bloodtimer_timeout() -> void:
	bone_attachment.get_child(0).blood_drip.emitting = false
	remove_blood()

func _on_damage_dealt(target: hurtbox_component) -> void:
	Global.player.camera.apply_shake(0.04)
	if !target.can_bleed:
		return
		
	var weapon_mesh_shader = bone_attachment.get_child(0).weapon_mesh.get_surface_override_material(0)
	var hand_mesh_shader = hands.get_surface_override_material(0)
	weapon_mesh_shader["shader_parameter/progress"] = clampf(weapon_mesh_shader["shader_parameter/progress"]+.05,0,.6)
	hand_mesh_shader["shader_parameter/progress"] = clampf(hand_mesh_shader["shader_parameter/progress"]+.05,0,.6)
	if weapon_mesh_shader["shader_parameter/progress"] >= .4 && bone_attachment.get_child(0).blood_drip != null:
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
	camera = get_viewport().get_camera_3d()
	cam_pos = camera.global_position
	cam_basis = camera.global_transform.basis
		
func stab():
	var anim_length = animation_tree.get("parameters/playback").get_current_length()
	attack_timer.wait_time = (anim_length / 5) / ray_count

	hits.clear()
	for i in range(ray_count):
				attack_timer.start()
				var forward = -cam_basis.z
				var up_axis = cam_basis.y
				
				var half_spread = stab_spread_angle / 2.0
				var angle_step = stab_spread_angle / (ray_count - 1) if ray_count > 1 else 0.0
				var current_angle = -half_spread + (i * angle_step)
				
				var area_direction = forward.rotated(up_axis, deg_to_rad(-current_angle))
				
				_perform_area_check(cam_pos, area_direction)
				
				await attack_timer.timeout
	

func shoot_arc(direction: Vector2i):
	var anim_length = animation_tree.get("parameters/playback").get_current_length()
	attack_timer.wait_time = (anim_length / 5) / ray_count

	hits.clear()

	if direction.x != 0:
		for i in range(ray_count):
			attack_timer.start()
			var forward = -cam_basis.z
			var up_axis = cam_basis.y
			
			var half_spread = spread_angle / 2.0
			var angle_step = spread_angle / (ray_count - 1) if ray_count > 1 else 0.0
			var current_angle = -half_spread + (i * angle_step)
			
			var area_direction = forward.rotated(up_axis * direction.x, deg_to_rad(-current_angle))
			
			_perform_area_check(cam_pos, area_direction)
			
			await attack_timer.timeout

	if direction.y != 0:
		for i in range(ray_count):
			attack_timer.start()
			var forward = -cam_basis.z
			var right_axis = cam_basis.x
			
			var half_spread = spread_angle / 2.0
			var angle_step = spread_angle / (ray_count - 1) if ray_count > 1 else 0.0
			var current_angle = -half_spread + (i * angle_step)
			
			var area_direction = forward.rotated(right_axis * direction.y, deg_to_rad(-current_angle))
			
			_perform_area_check(cam_pos, area_direction)
			
			await attack_timer.timeout


func _perform_area_check(origin: Vector3, direction: Vector3):
	var check_area = DamageComponent.new()
	check_area.collision_mask = 14
	check_area.damage_types = damage_component.damage_types
	check_area.status_types = damage_component.status_types
	check_area.stance_damage_value = damage_component.stance_damage_value
	check_area.source = Global.player
	if damage_component.hit_sound:
		check_area.hit_sound = damage_component.hit_sound
	check_area.damage_dealt.connect(_update_hits.bind(check_area))
	check_area.hits = hits
	get_tree().root.add_child(check_area)
	
	
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.1
	capsule.height = ray_length 
	
	var collision_node = CollisionShape3D.new()
	collision_node.shape = capsule
	collision_node.rotation.x = deg_to_rad(90) # Orient capsule forward along the Z axis
	check_area.add_child(collision_node)
	
	# 4. Position the area halfway along the range so it spans from origin to target
	var spawn_pos = origin + (direction * (ray_length / 2.0))
	check_area.global_position = spawn_pos
	check_area.global_transform.basis = Basis.looking_at(-direction, cam_basis.y)
	# 5. Wait exactly one physics frame for Godot to register overlaps
	await get_tree().create_timer(.25).timeout
	
	check_area.queue_free()
	

func _update_hits(types: Dictionary, actual: float, stance_damage: float, target: hurtbox_component, check_area: DamageComponent):
	hits.append(check_area.hits)
	
func _on_swing_state_exited() -> void:
	hits.clear()

func disable():
	can_attack = false
	@warning_ignore("shadowed_variable")
	var tween = get_tree().create_tween()
	tween.tween_property(arms_base, "rotation_degrees:x", -90, .25)
	#state_chart.send_event("lower")

func enable():
	can_attack = true
	@warning_ignore("shadowed_variable")
	var tween = get_tree().create_tween()
	tween.tween_property(arms_base, "rotation_degrees:x", 0, .25)

func activate_left():
	left_bone_attachment.get_child(0).activate()

func activate_right():
	bone_attachment.get_child(0).activate()

func shoot_left():
	left_bone_attachment.get_child(0).shoot()


func _on_ray_cast_3d_interaction_controller_pickable_grabbed(value: bool) -> void:
	if value:
		disable()
	else:
		enable()
		state_chart.send_event("idle")
