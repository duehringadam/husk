extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var movement_dir: Vector2
var is_kicking := false

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
	
	is_kicking = true
	animation_tree.set("parameters/conditions/kick", true)
	var anim = animation_tree.get_animation("standing_kick")
	await get_tree().create_timer(anim.length).timeout
	is_kicking = false
	animation_tree.set("parameters/conditions/kick", false)
