extends Node3D

@export var weapon: item: set = _set_item
@export var offhand: Node3D
@export var animation_state_machine: AnimationNodeStateMachine
@export var bone_attachment: BoneAttachment3D
@onready var animation_tree: AnimationTree = $ghoul_arms_new/AnimationTree
@onready var skeleton: Skeleton3D = $ghoul_arms_new/Armature/Skeleton3D

var attack_dir
var can_attack = true

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
		item_add.position = weapon.position
		item_add.rotation_degrees = weapon.rotation
		animation_state_machine = weapon.animation_state_machine
		animation_tree.tree_root = animation_state_machine
		animation_tree.active = false
		await get_tree().create_timer(.1).timeout
		animation_tree.active = true
		bone_attachment.add_child(item_add)

func unequip():
	weapon = null
	for i in bone_attachment.get_children():
		if i is not RemoteTransform3D:
			i.queue_free()

func _process(delta: float) -> void:
	attack_dir = Global.player.attack_dir
