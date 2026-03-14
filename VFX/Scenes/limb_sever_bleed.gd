class_name BloodParticles
extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var bleed_time: float = 10.0

func bleed():
	AudioManager.play_sound(load("res://sfx/spells/blood/ragecore29-htf-blood-splatter-explode-478992.mp3"),self.global_position,-15)
	animation_player.play("Init")
	await get_tree().create_timer(bleed_time).timeout
	animation_player.play("End")
	await animation_player.animation_finished
	self.queue_free()
