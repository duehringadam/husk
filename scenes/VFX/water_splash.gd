extends GPUParticles3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func activate():
	animation_player.play("init")

func deactivate():
	animation_player.stop()
