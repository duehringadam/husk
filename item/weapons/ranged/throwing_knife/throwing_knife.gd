extends Offhand

@export var knife: PackedScene

@onready var equip: AudioStreamPlayer3D = %equip
@onready var aim: AudioStreamPlayer3D = %aim
@onready var throw_sound: AudioStreamPlayer3D = %throw

var is_active: bool = false
var camera: Camera3D

func _ready() -> void:
	equip.play()
	
func activate():
	if !is_active:
		is_active = true
		aim.play()

func deactivate():
	pass

func play_equip():
	equip.play()

func _physics_process(delta: float) -> void:
	camera = Global.player.camera

func throw():
	if is_active:
		throw_sound.play()
		aim.play()
		var knife_projectile = knife.instantiate()
		knife_projectile.transform.basis = Global.player.camera.global_transform.basis
		get_tree().current_scene.add_child(knife_projectile)
		knife_projectile.global_position = camera.global_position
		var throw_direction = -camera.global_transform.basis.z.normalized()
		knife_projectile.apply_central_impulse(throw_direction * 50)
		is_active = false
