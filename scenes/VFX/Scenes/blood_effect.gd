extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func emit_blood(value: bool):
	if value:
		animation_player.play("Init")
	elif animation_player.has_animation("end"):
			animation_player.play("end")
