extends Node3D

signal unequip_item(_weapon: item)
signal equip_item(_weapon: item)

@export_subgroup("Weapon")
@export var mainhand_weapon: item
@export var offhand_weapon: item

@export_subgroup("armor")
@export var equipped_armor: armor
@export var hands: MeshInstance3D

@export_subgroup("bone_attachments")
@export var bone_attachment: BoneAttachment3D
@export var left_bone_attachment: BoneAttachment3D

@export_subgroup("Misc")
@export var animation_tree: AnimationTree
@export var anim_player: AnimationPlayer
@export var skeleton: Skeleton3D

@export var state_chart: StateChart

@export_subgroup("Combat")
@export var ray_length :float = 2
@export var ray_count: int = 16
@export var spread_angle: float = 30.0
@export_range(0,360) var stab_spread_angle: float = 30 # Spread 30 degrees

@onready var attack_timer: Timer = %attackTimer
@onready var arms_base: Node3D = $"ghoul_arms2(1)"
@onready var armor_equip: AudioStreamPlayer3D = $armorEquip

var space_state
var can_attack = true
var cam_basis: Basis
var cam_pos : Vector3
var camera: Camera3D
var hits: Array
var tween: Tween
var result
var query
var damage_component: DamageComponent

@export_group("Animation Resources")

@export_subgroup("mainhand")
@export var idle: AnimationNodeAnimation
@export var equip: AnimationNodeAnimation
@export var attack_1: AnimationNodeAnimation
@export var attack_2: AnimationNodeAnimation
@export var attack_3: AnimationNodeAnimation
@export var heavy_attack: AnimationNodeAnimation
@export var mainhand_lower: AnimationNodeAnimation
@export var twohand_equip: AnimationNodeAnimation

@export_subgroup("mainhand block")
@export var block_start: AnimationNodeAnimation
@export var block_idle: AnimationNodeAnimation
@export var block_hit: AnimationNodeAnimation
@export var block_stun: AnimationNodeAnimation

@export_subgroup("offhand")
@export var offhand_equip: AnimationNodeAnimation
@export var offhand_idle: AnimationNodeAnimation
@export var offhand_lower: AnimationNodeAnimation
@export var activate: AnimationNodeAnimation
@export var deactivate: AnimationNodeAnimation
@export var offhand_block_idle: AnimationNodeAnimation
@export var offhand_block_hit: AnimationNodeAnimation
@export var offhand_block_stun: AnimationNodeAnimation
@export var offhand_cant_use: AnimationNodeAnimation

var mainhand_animation_resources: ItemAnimations
var offhand_animation_resources: ItemAnimations

var unarmored_arms = preload("res://item/armor/chest/unarmored/unarmored_chest.tres")

func _ready() -> void:
	animation_tree.active = false
	SignalBus.connect("equip_item", _set_item)
	SignalBus.connect("unequip_mainhand", unequip_mainhand)
	SignalBus.connect("unequip_offhand", unequip_offhand)
	SignalBus.connect("unequip_armor", unequip_armor)
	set_mainhand_animations()
	set_offhand_animations()

func _set_item(new_item: item):
	if new_item != null:
			match new_item.item_type:
				ItemEquippableType.ITEM_EQUIPPABLE_TYPES.OFFHAND:
					offhand_weapon = new_item
					offhand_animation_resources = new_item.animations
					equip_offhand(new_item)
				ItemEquippableType.ITEM_EQUIPPABLE_TYPES.WEAPON:
					mainhand_weapon = new_item
					mainhand_animation_resources = new_item.animations
					equip_mainhand(mainhand_weapon)
				ItemEquippableType.ITEM_EQUIPPABLE_TYPES.ARMOR:
					if new_item.item_category == ItemEquippableType.ITEM_WEAPON_CATEGORY.CHEST_ARMOR:
						equipped_armor = new_item
						equip_armor(new_item)
					
	state_chart.send_event("idle")

func equip_armor(new_armor: armor):
	equipped_armor = new_armor
	hands.mesh = new_armor.mesh
	hands.skin = new_armor.skin
	hands.material_override = new_armor.material
	armor_equip.stream = new_armor.equip_sfx
	armor_equip.pitch_scale = randf_range(0.8,1.2)
	armor_equip.play()
	equip_item.emit(new_armor)

func unequip_armor():
	hands.mesh = unarmored_arms.mesh
	hands.skin =  unarmored_arms.skin
	hands.material_override =  unarmored_arms.material
	
	armor_equip.stream = equipped_armor.equip_sfx
	armor_equip.pitch_scale = randf_range(0.8,1.2)
	armor_equip.play()
	unequip_item.emit(equipped_armor)
	equipped_armor = null

func equip_mainhand(new_item: item):
	if animation_tree.active:
		if new_item.two_handed:
			animation_tree["parameters/playback"].travel("twoHandNewEquip")
		else:
			animation_tree["parameters/playback"].travel("mainhandNewEquip")
	else:
		animation_tree.active = true
		
	if new_item.two_handed:
		unequip_offhand()
	elif bone_attachment.get_child_count() > 0:
		unequip_mainhand(new_item)
	
	var item_add = new_item.item_scene.instantiate()
	
	item_add.position = mainhand_weapon.position
	item_add.rotation_degrees = mainhand_weapon.rotation

	set_mainhand_animations()

	await get_tree().create_timer(.1).timeout
	bone_attachment.add_child(item_add)
	damage_component = bone_attachment.get_child(0).damage_component
	bone_attachment.get_child(0).damage_component.damage_types = new_item.item_stats.final_damage
	ray_length = new_item.item_stats.range
	
	if new_item.item_left_scene:
		var item_left_add = new_item.item_left_scene.instantiate()
		item_left_add.position = mainhand_weapon.left_position
		item_left_add.rotation_degrees = mainhand_weapon.left_rotation
		left_bone_attachment.add_child(item_left_add)
	enable()

func set_mainhand_animations():
	if mainhand_weapon != null:
		idle.animation = mainhand_animation_resources.idle
		equip.animation = mainhand_animation_resources.equip
		attack_1.animation = mainhand_animation_resources.attack_1
		attack_2.animation = mainhand_animation_resources.attack_2
		attack_3.animation = mainhand_animation_resources.attack_3
		block_start.animation = mainhand_animation_resources.block_start
		block_hit.animation = mainhand_animation_resources.block_hit
		block_stun.animation = mainhand_animation_resources.block_stun
		mainhand_lower.animation = mainhand_animation_resources.mainhand_lower
		
		if mainhand_weapon.two_handed:
			twohand_equip.animation = mainhand_animation_resources.equip
			animation_tree.set("parameters/attackBlendTree/offhandBlend/blend_amount", 0.0)
		else:
			animation_tree.set("parameters/attackBlendTree/offhandBlend/blend_amount", 1.0)
		
	if mainhand_weapon == null:
		idle.animation = &"mainhand_empty"
		equip.animation = &"mainhand_empty"
		attack_1.animation = &"mainhand_empty"
		attack_2.animation = &"mainhand_empty"
		attack_3.animation = &"mainhand_empty"
		block_start.animation = &"mainhand_empty"
		block_idle.animation = &"mainhand_empty"
		block_hit.animation = &"mainhand_empty"
		block_stun.animation = &"mainhand_empty"
		mainhand_lower.animation = &"mainhand_empty"
	
func set_offhand_animations():
	if offhand_weapon != null:
		offhand_equip.animation = offhand_animation_resources.offhand_equip
		offhand_idle.animation = offhand_animation_resources.offhand_idle
		offhand_lower.animation = offhand_animation_resources.offhand_lower
		activate.animation = offhand_animation_resources.activate
		deactivate.animation = offhand_animation_resources.deactivate
		#offhand_block_idle.animation = offhand_animation_resources.offhand_block_idle
		#offhand_block_stun.animation = offhand_animation_resources.offhand_block_stun
		#offhand_cant_use.animation = offhand_animation_resources.offhand_cant_use
	if offhand_weapon == null:
		offhand_equip.animation = &"offhand_empty"
		offhand_idle.animation = &"offhand_empty"
		offhand_lower.animation = &"offhand_empty"
		activate.animation = &"offhand_empty"
		deactivate.animation = &"offhand_empty"
		#offhand_block_idle.animation = &"offhand_empty"
		#offhand_block_stun.animation = &"offhand_empty"
		#offhand_cant_use.animation = &"offhand_empty"

func equip_offhand(new_item: item):
	if animation_tree.active:
		animation_tree["parameters/playback"].travel("offhandNewEquip")
	else:
		animation_tree.active = true
		
	if mainhand_weapon:
		if mainhand_weapon.two_handed:
			unequip_mainhand()
	if left_bone_attachment.get_child_count() > 0:
		unequip_offhand(new_item)
	
	var item_add = new_item.item_scene.instantiate()

	item_add.position = offhand_weapon.position
	item_add.rotation_degrees = offhand_weapon.rotation

	set_offhand_animations()
	
	left_bone_attachment.add_child(item_add)
	
	if new_item.item_left_scene:
		var item_left_add = new_item.item_left_scene.instantiate()
		item_left_add.position = mainhand_weapon.left_position
		item_left_add.rotation_degrees = mainhand_weapon.left_rotation
		left_bone_attachment.add_child(item_left_add)
	enable()

func unequip_mainhand(replacement_item: item = null):
	for i in bone_attachment.get_children():
		i.queue_free()
	mainhand_weapon = replacement_item
	unequip_item.emit()
	set_mainhand_animations()

func unequip_offhand(replacement_item: item = null):
	for i in left_bone_attachment.get_children():
		i.queue_free()
	offhand_weapon = replacement_item
	unequip_item.emit()
	set_offhand_animations()

func _on_bloodtimer_timeout() -> void:
	bone_attachment.get_child(0).blood_drip.emitting = false
	remove_blood()

func _on_damage_dealt(target: hurtbox_component) -> void:
	Global.player.camera.apply_shake(0.04)
	if !target.can_bleed:
		return
		
	if bone_attachment.get_child(0).blood_decals.size() <= 0: return
	
	for i in bone_attachment.get_child(0).blood_decals:
		if i.modulate.a < 1.0:
			i.modulate.a += 0.5
			return
	
	bone_attachment.get_child(0).blood_drip.emitting = true
	bone_attachment.get_child(0).bloodtimer.start()

func remove_blood():
	bone_attachment.get_child(0).blood_drip.emitting = false
	var weapon_mesh_shader = bone_attachment.get_child(0).weapon_mesh.get_active_material(0)
	var hand_mesh_shader = hands.get_active_material(0)
	tween = get_tree().create_tween()
	tween.tween_property(weapon_mesh_shader.next_pass,"shader_parameter/progress",0,60)
	tween.set_parallel()
	tween.tween_property(hand_mesh_shader.next_pass,"shader_parameter/progress",0,60)

func _physics_process(delta: float) -> void:
	camera = get_viewport().get_camera_3d()
	cam_pos = camera.global_position
	cam_basis = camera.global_transform.basis

func stab():
	var anim_length = animation_tree.get("parameters/playback").get_current_length()
	attack_timer.wait_time = (anim_length / 4) / ray_count

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

func shoot_arc(direction: Vector2i, attack_shape_curve: Curve):
	
	if not camera:
		return
		
	var viewport_size = get_viewport().get_visible_rect().size
	var anim_length = animation_tree.get("parameters/attackBlendTree/output/current_length")

	attack_timer.wait_time = (anim_length/ 4) / ray_count

	var degrees_per_pixel_y = camera.fov / viewport_size.y
	var aspect_ratio = viewport_size.x / viewport_size.y
	var degrees_per_pixel_x = (camera.fov * aspect_ratio) / viewport_size.x
	
	var spread_width_pixels = spread_angle / degrees_per_pixel_x
	var spread_height_pixels = spread_angle / degrees_per_pixel_y
	
	var screen_center = viewport_size / 2.0

	hits.clear()
	
	if direction.x != 0:
		for i in range(ray_count):
			attack_timer.start()
			
			var t = float(i) / (ray_count - 1) if ray_count > 1 else 0.5
			if direction.x < 0: 
				t = 1.0 - t 
			
			var curve_y = attack_shape_curve.sample(t) if attack_shape_curve else 0.5
			
			
			var start_x = screen_center.x - (spread_width_pixels / 2.0)
			var screen_x = start_x + (t * spread_width_pixels)
			
		
			var start_y = screen_center.y - (spread_height_pixels / 2.0)
			var screen_y = start_y + ((1.0 - curve_y) * spread_height_pixels)
			
			var screen_point = Vector2(screen_x, screen_y)
			var area_direction: Vector3 = camera.project_ray_normal(screen_point)
			
			_perform_area_check(cam_pos, area_direction)
			
			await attack_timer.timeout


	if direction.y != 0:
		for i in range(ray_count):
			attack_timer.start()
			
			var t = float(i) / (ray_count - 1) if ray_count > 1 else 0.5
			if direction.y < 0:
				t = 1.0 - t 
				
			var curve_y = attack_shape_curve.sample(t) if attack_shape_curve else 0.5
			
			
			var start_y = screen_center.y - (spread_height_pixels / 2.0)
			var screen_y = start_y + (t * spread_height_pixels)
			
			
			var start_x = screen_center.x - (spread_width_pixels / 2.0)
			var screen_x = start_x + ((1.0 - curve_y) * spread_width_pixels)
			
			var screen_point = Vector2(screen_x, screen_y)
			var area_direction: Vector3 = camera.project_ray_normal(screen_point)
			
			_perform_area_check(cam_pos, area_direction)
			
			await attack_timer.timeout

func _perform_area_check(origin: Vector3, direction: Vector3):
	var check_area = DamageComponent.new()
	check_area.collision_mask = 14
	check_area.damage_types = damage_component.damage_types
	check_area.status_types = damage_component.status_types
	check_area.stance_damage_value = damage_component.stance_damage_value
	check_area.damage_interval = .25
	check_area.source = Global.player
	if damage_component.hit_sound:
		check_area.hit_sound = damage_component.hit_sound
	check_area.damage_dealt.connect(_update_hits.bind(check_area))
	check_area.hits = hits
	get_tree().root.add_child(check_area)
	
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.05
	capsule.height = ray_length 
	
	var collision_node = CollisionShape3D.new()
	collision_node.shape = capsule
	collision_node.debug_color = Color.RED
	collision_node.rotation.x = deg_to_rad(90) # Orient capsule forward along the Z axis
	check_area.add_child(collision_node)
	
	#DebugDraw3D.draw_ray(origin,direction,mainhand_weapon.item_stats.range,Color.RED,1)
	
	var spawn_pos = origin + (direction * (ray_length / 2.0))
	check_area.global_position = spawn_pos
	check_area.global_transform.basis = Basis.looking_at(-direction, cam_basis.y)
	
	await get_tree().create_timer(.25).timeout
	
	check_area.queue_free()

func _update_hits(types: Dictionary, actual: float, stance_damage: float, target: hurtbox_component,slow_amount: float, check_area: DamageComponent):
	hits.append(check_area.hits)
	_on_damage_dealt(target)

func _on_swing_state_exited() -> void:
	hits.clear()

func disable():
	can_attack = false
	@warning_ignore("shadowed_variable")
	var tween = get_tree().create_tween()
	tween.tween_property(arms_base, "rotation_degrees:x", -90, .25)

func enable():
	@warning_ignore("shadowed_variable")
	var tween = get_tree().create_tween()
	tween.tween_property(arms_base, "rotation_degrees:x", 0, .25)
	tween.tween_callback(func(): can_attack = true)

func activate_left():
	left_bone_attachment.get_child(0).activate()

func activate_right():
	bone_attachment.get_child(0).activate(true)

func deactivate_right():
	bone_attachment.get_child(0).activate(false)

func shoot_left():
	left_bone_attachment.get_child(0).shoot()

func _on_ray_cast_3d_interaction_controller_pickable_grabbed(value: bool) -> void:
	if value:
		disable()
	else:
		enable()
		state_chart.send_event("idle")

func _on_hurtbox_component_blocked_attack() -> void:
	var _weapon
	
	if offhand_weapon == null:
		_weapon = bone_attachment.get_child(0)
		animation_tree.set("parameters/mainhandBlockBlendTree/Transition/transition_request", "hit")
	else:
		_weapon = left_bone_attachment.get_child(0)
		animation_tree.set("parameters/offhandActivateBlendTree/Transition/transition_request", "hit")
	
	if _weapon:
		if _weapon.block_sound:
			_weapon.block_sound.pitch_scale = randf_range(0.9,1.1)
			_weapon.block_sound.play()


func _on_hurtbox_component_stance_broken() -> void:
	state_chart.send_event("stun")
