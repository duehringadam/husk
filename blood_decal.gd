extends Decal

func _ready() -> void:
	await get_tree().create_timer(60).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0,1)
	await tween.finished
	queue_free()
	
