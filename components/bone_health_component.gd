class_name BoneHealthComponent
extends HealthComponent

signal bones_severed(bones: Array)

@export var bones_to_affect: Array[PhysicalBone3D]
@export var physical_skeleton: PhysicalBoneSimulator3D
@export var skeleton: Skeleton3D
@export var limb_to_spawn: PackedScene

var blood_particles = preload("res://scenes/npc/Ghoul Animated/gore/pickable/limb_sever_bleed.tscn")

var last_damage_taken

func _ready() -> void:
	current_health = max_health
	emit_signal("max_health_changed", 0, max_health)
	emit_signal("health_changed", 0, current_health)
	

func modify_health(amount: float):
	current_health = clampf(current_health + amount, 0, max_health)
	emit_signal("health_changed", amount, current_health)
	if current_health <= 0:
		emit_signal("died")
		match last_damage_taken:
			DamageTypes.DAMAGE_TYPES.SLASH:
				sever_bones()
			DamageTypes.DAMAGE_TYPES.STRIKE:
				break_bones()
			_:
				return
	
func modify_max_health(amount: float):
	max_health += amount
	modify_health(max_health)
	emit_signal("max_health_changed", amount, max_health)

func break_bones():
	var bone_name_array: Array
	for i in bones_to_affect:
		if i.bone_name.to_lower().contains("head"):
			bone_name_array.erase(i)
		else:
			bone_name_array.append(i.bone_name)
	if bone_name_array.size() > 0:
		print(bone_name_array)
		physical_skeleton.physical_bones_start_simulation(bone_name_array)

func sever_bones():
	var limb_to_spawn_add = limb_to_spawn.instantiate()
	limb_to_spawn_add.global_transform = self.global_transform
	get_tree().current_scene.add_child(limb_to_spawn_add)
	
	var bone_names : Array
	if limb_to_spawn_add.is_inside_tree():
		for i in bones_to_affect:
			if is_instance_valid(i):
				var bone = skeleton.find_bone(i.bone_name)
				skeleton.set_bone_pose_scale(bone, (Vector3(0.01,0.01,0.01)))
				i.queue_free()
				bone_names.append(i.bone_name)
	bones_severed.emit(bone_names)
	AudioManager.play_sound(load("res://sfx/horror-bone-crack-352450.mp3"),self.global_position,0)
