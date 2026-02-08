extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var kick_damage_component: Area3D = $Root/Skeleton3D/BoneAttachment3D/kick_damage_component

var movement_dir: Vector2
var is_kicking := false
var secondary_active_bool:= false
func _ready() -> void:
	SignalBus.connect("secondary_active", secondary_active)

func secondary_active(value: bool):
	secondary_active_bool = value
	
func _process(delta: float) -> void:
	animation_tree["parameters/crouchBlendSpace/blend_position"] = lerp(animation_tree["parameters/crouchBlendSpace/blend_position"],movement_dir,10*delta)
	animation_tree["parameters/standingBlendSpace/blend_position"] = lerp(animation_tree["parameters/standingBlendSpace/blend_position"],movement_dir,10*delta)
	
func crouch(value: bool):
	if value:
		animation_tree.set("parameters/conditions/crouch", true)
		animation_tree.set("parameters/conditions/stand", false)
	else:
		animation_tree.set("parameters/conditions/crouch", false)
		animation_tree.set("parameters/conditions/stand", true)

func kick():
	if is_kicking: return
	if secondary_active_bool: return
	SignalBus.emit_signal("kick_active", true)
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov",Global.camera_fov+10,.25)
	is_kicking = true
	animation_tree.set("parameters/conditions/kick", true)
	var anim = animation_tree.get_animation("standing_kick")
	await get_tree().create_timer(anim.length/2).timeout
	SignalBus.emit_signal("kick_active", false)
	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov",Global.camera_fov,.25)
	is_kicking = false
	animation_tree.set("parameters/conditions/endkick", true)
	animation_tree.set("parameters/conditions/kick", false)
	await animation_tree.animation_started
	animation_tree.set("parameters/conditions/endkick", false)


func _on_kick_damage_component_damage_dealt(types, actual: float, stance_damage: float, target: hurtbox_component) -> void:
	Global.player.camera.apply_shake()
