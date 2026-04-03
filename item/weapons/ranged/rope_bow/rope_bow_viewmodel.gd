extends Node3D

@export var weapon_initial_position: Vector3
@export var bolt_add: PackedScene
@onready var ray: RayCast3D = $RayCast3D


func _ready() -> void:
	self.position = weapon_initial_position


func shoot():
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
	
