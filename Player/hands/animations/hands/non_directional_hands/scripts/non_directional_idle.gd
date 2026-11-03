extends Node

@export var hold_duration: float = 0.5
@export var weapon: Node3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree
@export var main_bone_attach: BoneAttachment3D
@export var off_bone_attach: BoneAttachment3D

@onready var end_timer: Timer = $"../../swing/endTimer"

var current_held_duration: float = 0.0

func _on_idle_state_entered() -> void:
	current_held_duration = 0
	end_timer.start()
	animation_tree.set("parameters/conditions/attack", false)
	animation_tree.set("parameters/conditions/idle", true)
	if main_bone_attach.get_child_count() > 0:
		SignalBus.emit_signal("primary_active", false)
	weapon.can_attack = true


func _on_idle_state_exited() -> void:
	current_held_duration = 0
	animation_tree.set("parameters/conditions/idle", false)
	weapon.can_attack = false

func _on_idle_state_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_secondary") && weapon.offhand_weapon && weapon.can_attack:
		state_chart.send_event("offhand")
	elif event.is_action_pressed("attack_secondary") && !weapon.offhand_weapon && weapon.can_attack:
		state_chart.send_event("block")


func _on_idle_state_processing(delta: float) -> void:
	if weapon.mainhand_weapon && weapon.can_attack && Global.player.can_attack:
		if Input.is_action_pressed("attack_primary"):
			current_held_duration += delta
			SignalBus.emit_signal("primary_active", true)
			animation_tree.set("parameters/conditions/attack",true)
		if Input.is_action_just_released("attack_primary") && current_held_duration < hold_duration:
			animation_tree.set("parameters/conditions/attack",true)
			state_chart.send_event("swing")
		if current_held_duration >= hold_duration:
			state_chart.send_event("heavy")
