extends GPUParticles3D

@onready var blood_pos: RayCast3D = $blood_pos
@onready var bleed_timer: Timer = $bleed_timer
@onready var blood_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D

var blood_decal = preload("res://blood_decal.tscn")

func take_damage() -> void:
	emitting = true
	if blood_pos.is_colliding():
		blood_sound.play()
		var blood_decal_add = blood_decal.instantiate()
		get_tree().current_scene.add_child(blood_decal_add)
		blood_decal_add.global_rotation.y = randf_range(-360,360)
		blood_decal_add.global_position = blood_pos.get_collision_point()
		blood_decal_add.global_position.x += randf_range(-.3,.3)
		blood_decal_add.global_position.z += randf_range(-.3,.3)
		
		
func _on_timer_timeout() -> void:
	self.emitting = false
	bleed_timer.stop()
