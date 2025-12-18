extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var skeleton: PhysicalBoneSimulator3D = $Armature/Skeleton3D/PhysicalBoneSimulator3D

var timer: float

func _process(delta: float) -> void:
	timer += delta
	if timer >= 0.1:
		animation_player.advance(timer)
		timer -= 0.1
	
func _ready() -> void:
	AudioManager.play_sound(load("res://scenes/short-monster-scream-105026.mp3"),self.global_position,-15)
	animation_player.play("idlebite")

func _on_hurtbox_component_damage_taken(actual: float, source: DamageComponent, hit_dir: Vector3) -> void:
	skeleton.physical_bones_start_simulation()
