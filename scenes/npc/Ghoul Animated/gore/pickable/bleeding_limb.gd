extends Node3D

@onready var blood_pos: RayCast3D = $blood_pos
@onready var bleed_timer: Timer = $bleed_timer
@onready var blood_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var blood_decal = preload("res://blood_decal.tscn")

func _ready() -> void:
	animation_player.play("Init")

func take_damage() -> void:
	if blood_pos.is_colliding():
		var blood_decal_add = blood_decal.instantiate()
		get_tree().current_scene.add_child(blood_decal_add)
		blood_decal_add.global_position = blood_pos.get_collision_point()
		blood_decal_add.emitting = true
		
		
func _on_timer_timeout() -> void:
	animation_player.play("End")
	bleed_timer.stop()
