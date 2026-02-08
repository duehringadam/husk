extends VisibleOnScreenNotifier3D

func _ready() -> void:
	DebugDraw3D.draw_sphere(self.global_position,1,Color.RED,5)
