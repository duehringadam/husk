extends RayCast3D

var collider_stored
var ground_type: set = _update_ground_type
@export var footstep_sounds: AudioStreamPlayer3D

var deep_water = preload("res://Player/sfx/water_footsteps.tres")
var default = preload("res://Player/sfx/dirt_footsteps.tres")
var wood = preload("res://Player/sfx/footsteps/wood/wood_footsteps.tres")
var stone = preload("res://Player/sfx/footsteps/stone/footstep_stone.tres")

func _process(delta: float) -> void:
	if is_colliding() and collider_stored != get_collider():
		if get_collider().has_meta("ground_type"):
			collider_stored = get_collider()
			ground_type = collider_stored.get_meta("ground_type")
		if get_collider() is Terrain3D:
			collider_stored = get_collider()
			footstep_sounds.stream = default


func _update_ground_type(value: String):
	match value:
		"water":
			footstep_sounds.stream = deep_water
		"stone":
			footstep_sounds.stream = stone
		"wood":
			footstep_sounds.stream = wood
		_:
			footstep_sounds.stream = default
