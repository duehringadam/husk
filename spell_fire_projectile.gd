extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var damage_component: DamageComponent = $DamageComponent

func _ready() -> void:
	animation_player.play("explode")
	await animation_player.animation_finished
	queue_free()
