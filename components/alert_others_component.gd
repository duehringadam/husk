extends Area3D

@export var source: npc

func _physics_process(delta: float) -> void:
	if monitoring:
		for other in get_overlapping_bodies():
			if other is npc:
				other.target = source.target
