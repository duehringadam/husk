extends Node3D

@export var bolt_add: PackedScene
@onready var ray: RayCast3D = $RayCast3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var draw: AudioStreamPlayer3D = $draw
@onready var shoot_sfx: AudioStreamPlayer3D = $shoot
@onready var hold: AudioStreamPlayer3D = $hold
@onready var equip: AudioStreamPlayer3D = $equip

func _ready() -> void:
	equip.play()

func activate():
	animation_player.play("draw")
	draw.play()
	hold.play()

func shoot():
	animation_player.play("shoot")
	hold.stop()
	shoot_sfx.play()
	Global.player.camera.apply_shake()
	var bolt = bolt_add.instantiate()
	get_tree().current_scene.add_child(bolt)
	bolt.source = Global.player
	var screen_center = get_viewport().size/2
	var origin = Global.player.camera.project_ray_origin(screen_center)
	var end = origin + Global.player.camera.project_ray_normal(screen_center) * 100
	ray.look_at(end)
	bolt.global_position = origin
	bolt.transform.basis = ray.global_transform.basis
	
