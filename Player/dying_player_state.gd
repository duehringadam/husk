class_name dyingPlayerState
extends State

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func enter(previous_state)->void:
	animation_player.play("death")
	await animation_player.animation_finished
	get_tree().reload_current_scene()

func update(delta):
	Global.player.update_velocity()
