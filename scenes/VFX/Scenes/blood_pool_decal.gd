extends Decal

func _ready() -> void:
	rotation_degrees.y = randf_range(0,360)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "size", Vector3(1.0,0.2,1.0),.25).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(90).timeout
	self.queue_free()
