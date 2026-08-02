extends Node3D

@export var separation_ray: CollisionShape3D
@export var player: Player
@onready var _step_base: RayCast3D = $stepBase
@onready var _step_height: RayCast3D = $stepHeight

func _process(delta: float) -> void:
	
	set_rotation_degrees(Vector3(0, rad_to_deg(atan2(-player.input_dir.x, -player.input_dir.z)), 0))
	
	var step_base = _step_base.get_collider()
	var step_height = _step_height.get_collider()
	
	
	if (step_base != null && step_height != null) or (step_base == null && step_height == null):
		separation_ray.disabled = true
	if step_base == null and step_height != null:
		separation_ray.disabled = true
	if (step_base != null and step_height == null) && abs(_step_base.get_collision_normal().x) > Global.player.floor_max_angle:
		separation_ray.disabled = false
