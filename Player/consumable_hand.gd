extends Node3D

signal active(value: bool)

@export var consumable_item: item: set = _set_item
@export var mainhand: Node3D
@export var offhand: Node3D
@export var animation_state_machine :AnimationNodeStateMachine
@export var animation_tree: AnimationTree
@export var bone_attachment: BoneAttachment3D
@onready var arms_base: Node3D = $"ghoul_arms2(1)"
@onready var animation_player: AnimationPlayer = $"ghoul_arms2(1)/AnimationPlayer"
var can_activate: bool = true
func _ready() -> void:
	#SignalBus.connect("primary_active", _update_primary_active)
	#Make sure this arm is hidden until it is needed
	visible = false

func _set_item(new_item):
	if can_activate:
		can_activate = false
	else:
		return
	var right = mainhand.can_attack
	var left = offhand.can_activate
	if left:
		mainhand.disable()
	if right:
		offhand.disable()
	await get_tree().create_timer(0.25).timeout
	enable()
	mainhand.visible = false
	offhand.visible = false
	await get_tree().create_timer(0.25).timeout
	if new_item != null:
		consumable_item = new_item
		if bone_attachment.get_child_count() != 0:
			unequip()
		var item_add = new_item.item_scene.instantiate()
		item_add.position = consumable_item.position
		item_add.rotation_degrees = consumable_item.rotation
		animation_state_machine = consumable_item.animation_state_machine
		animation_tree.tree_root = animation_state_machine
		animation_tree.active = false
		await get_tree().create_timer(.1).timeout
		animation_tree.active = true
		bone_attachment.add_child(item_add)
		activate()
	await get_tree().create_timer(1.6167).timeout
	unequip()
	disable()
	await get_tree().create_timer(0.25).timeout
	if right:
		mainhand.enable()
		mainhand.visible = true
	if left:
		offhand.enable()
		offhand.visible = true
	can_activate = true

func unequip():
	consumable_item = null
	for i in bone_attachment.get_children():
		i.queue_free()
	#animation_tree.active = false

func activate():
	bone_attachment.get_child(0).activate()

func disable():
	var tween = get_tree().create_tween()
	tween.tween_property(arms_base, "rotation_degrees:x", -90, .25)
	await get_tree().create_timer(0.25).timeout
	visible = false
	
func enable():
	visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(arms_base, "rotation_degrees:x", 0, .25)
