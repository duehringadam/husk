extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var timer: float = 0.0

func _ready():
	animation_player.play("Idle")

func _process(delta: float) -> void:
	timer += delta
	if timer >= 0.15:
		animation_player.advance(timer)
		timer = 0
