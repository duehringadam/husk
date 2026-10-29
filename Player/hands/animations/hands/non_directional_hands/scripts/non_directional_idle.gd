extends Node

@export var weapon: Node3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree
@export var main_bone_attach: BoneAttachment3D
@export var off_bone_attach: BoneAttachment3D

@onready var end_timer: Timer = $"../../swing/endTimer"

func _on_idle_state_entered() -> void:
	end_timer.start()
	animation_tree.set("parameters/conditions/attack", false)
	animation_tree.set("parameters/conditions/idle", true)
	if main_bone_attach.get_child_count() > 0:
		SignalBus.emit_signal("primary_active", false)
	weapon.can_attack = true


func _on_idle_state_exited() -> void:
	animation_tree.set("parameters/conditions/idle", false)
	if main_bone_attach.get_child_count() > 0:
		SignalBus.emit_signal("primary_active", true)
	weapon.can_attack = false
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov",Global.camera_fov+10,.25)


func _on_idle_state_physics_processing(delta: float) -> void:
	await get_tree().physics_frame


func _on_idle_state_input(event: InputEvent) -> void:
	if weapon.mainhand_weapon:
		if event.is_action_pressed("attack_primary") && weapon.can_attack && Global.player.can_attack:
			state_chart.send_event("swing")

	if event.is_action_pressed("attack_secondary") && weapon.offhand_weapon && weapon.can_attack:
		state_chart.send_event("offhand")
	elif event.is_action_pressed("attack_secondary") && !weapon.offhand_weapon && weapon.can_attack:
		state_chart.send_event("block")
