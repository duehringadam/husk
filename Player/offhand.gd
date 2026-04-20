extends Node3D

@export var weapon: item: set = _set_item
@export var mainhand: Node3D
@export var animation_state_machine :AnimationNodeStateMachine
@export var animation_tree: AnimationTree
@export var bone_attachment: BoneAttachment3D
@export var state_chart: StateChart
var can_activate: bool = true

func _set_item(new_item):
	if new_item != null:
		weapon = new_item
		if mainhand.weapon != null:
			if mainhand.weapon.two_handed:
				mainhand.unequip()
		if bone_attachment.get_child_count() != 0:
			unequip()
		state_chart.send_event("idle")
		var item_add = new_item.item_scene.instantiate()
		item_add.position = weapon.position
		item_add.rotation_degrees = weapon.rotation
		animation_state_machine = weapon.animation_state_machine
		animation_tree.tree_root = animation_state_machine
		animation_tree.active = false
		await get_tree().create_timer(.1).timeout
		animation_tree.active = true
		bone_attachment.add_child(item_add)

func unequip():
	state_chart.send_event("lower")
	weapon = null
	for i in bone_attachment.get_children():
		i.queue_free()

func activate():
	bone_attachment.get_child(0).activate()
