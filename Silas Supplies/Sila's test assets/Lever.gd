class_name Lever
extends Node3D
var is_active = false
@export var TheDoor: Door
@export var singleUse = false
@export var timer: Timer
@export var timerstart = false
@onready var animation_player: AnimationPlayer = $Node3D/AnimationPlayer
@onready var static_body_3d: StaticBody3D = $StaticBody3D




func open():
		TheDoor.activate()
		animation_player.play("Level Flip")
func closed():
		TheDoor.activate()
		animation_player.play("Level Flip", -1, -1, true)


func _on_interact_on_complete(controller: InteractionController) -> void:
	if singleUse and is_active:
		static_body_3d.collision_layer = 2
		return

	if TheDoor.animation_player.is_playing() or animation_player.is_playing():
		return
	if is_active:
		is_active = false
		closed()
	else:
		is_active = true
		open()
