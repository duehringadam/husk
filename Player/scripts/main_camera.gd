extends Camera3D

@onready var camera_animation_player: AnimationPlayer = %CameraAnimationPlayer

func _ready() -> void:
	print("hi")
	SignalBus.connect("primary_active", animate_camera)
	
func animate_camera(value: bool):
	camera_animation_player.play("swing_left")
