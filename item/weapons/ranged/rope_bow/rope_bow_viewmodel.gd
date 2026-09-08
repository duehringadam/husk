extends Node3D

@export var bolt_add: PackedScene
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
	var camera = Global.player.camera
	animation_player.play("shoot")
	hold.stop()
	shoot_sfx.play()
	var bolt = bolt_add.instantiate()
	get_tree().current_scene.add_child(bolt)
	bolt.transform.basis = Global.player.camera.global_transform.basis
	if "impact_dir" in bolt:
		bolt.impact_dir = -camera.global_transform.basis.z.normalized()
	bolt.global_position = camera.global_position
	var throw_direction = -camera.global_transform.basis.z.normalized()
	bolt.apply_central_impulse(throw_direction * 75)
	bolt.apply_torque(Vector3(0,0,1.0))
	
