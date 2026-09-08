extends Node3D

@onready var blood_pos: RayCast3D = $blood_pos
@onready var bleed_timer: Timer = $bleed_timer
@onready var blood_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var blood_decal = preload("res://scenes/VFX/Scenes/Blood_Pool_Decal.tscn")


func take_damage() -> void:
	if blood_pos.is_colliding():
		var blood_decal_add = blood_decal.instantiate()
		get_tree().current_scene.add_child(blood_decal_add)
		
		var hit_position = blood_pos.get_collision_point()
		var hit_normal = blood_pos.get_collision_normal()
		var up_vector = Vector3.UP if abs(hit_normal.dot(Vector3.UP)) < 0.99 else Vector3.FORWARD
	
		blood_decal_add.global_position = hit_position + Vector3(-randf_range(0.1,0.3), 0.0, randf_range(0.1,0.3))
		blood_decal_add.look_at(hit_position + hit_normal, up_vector)
		blood_decal_add.rotate_object_local(Vector3.RIGHT, PI/2.0)
		
func _on_timer_timeout() -> void:
	animation_player.play("End")
	bleed_timer.stop()
