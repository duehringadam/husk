extends Camera3D

@export var main_camera: Camera3D

func _ready() -> void:
	environment = get_world_3d().environment
 
func _process(delta: float) -> void:
	global_transform = main_camera.global_transform
