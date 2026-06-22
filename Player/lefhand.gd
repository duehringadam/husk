extends Node3D

signal active(value: bool)

@export var weapon: item: set = _set_item
@export var mainhand: Node3D
@export var animation_state_machine :AnimationNodeStateMachine
@export var animation_tree: AnimationTree
@export var bone_attachment: BoneAttachment3D
@export var state_chart: StateChart

@onready var arms_base: Node3D = $"ghoul_arms2(1)"

var can_activate: bool = true
var telekinesis_hold_bool: bool = false

func _ready() -> void:
	SignalBus.connect("telekinesis_hold", telekinesis_hold)
	SignalBus.connect("telekinesis_throw", telekinesis_throw)
	SignalBus.connect("telekinesis_fail", telekinesis_fail)
	SignalBus.connect("primary_active", _update_primary_active)

func _update_primary_active(value: bool):
	can_activate = !value

func _set_item(new_item):
	if new_item != null:
		weapon = new_item
		if mainhand.weapon != null:
			if mainhand.weapon.two_handed:
				mainhand.unequip()
		if bone_attachment.get_child_count() != 0:
			unequip()
		state_chart.send_event("idle")
		enable()
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
	#animation_tree.active = false

func throw():
	bone_attachment.get_child(0).throw()

func activate():
	bone_attachment.get_child(0).activate()

func disable():
	can_activate = false
	var tween = get_tree().create_tween()
	tween.tween_property(arms_base, "rotation_degrees:x", -90, .25)
	
func enable():
	can_activate = true
	var tween = get_tree().create_tween()
	tween.tween_property(arms_base, "rotation_degrees:x", 0, .25)

func telekinesis_hold():
	telekinesis_hold_bool = true
	animation_tree.set("parameters/conditions/throw", false)
	animation_tree.set("parameters/conditions/hold", true)
	animation_tree.set("parameters/conditions/idle", false)

func telekinesis_throw():
	telekinesis_hold_bool = false
	animation_tree.set("parameters/conditions/hold", false)
	animation_tree.set("parameters/conditions/throw", true)
	animation_tree.set("parameters/conditions/idle", false)
	
func telekinesis_fail():
	telekinesis_hold_bool = false
	state_chart.send_event("cant_use")
	animation_tree.set("parameters/conditions/throw", false)
	animation_tree.set("parameters/conditions/hold", false)


func _on_ray_cast_3d_interaction_controller_pickable_grabbed(value: bool) -> void:
	if value and !telekinesis_hold_bool:
		disable()
	elif !value:
		enable()
		
