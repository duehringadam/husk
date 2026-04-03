extends PhysicalBoneSimulator3D

var timer: float = 0

func _ready() -> void:
	physical_bones_start_simulation()

#func _process(delta: float) -> void:
	#timer += delta
	#if timer >= 0.15:
		#active = false
		#timer -= 0.15
