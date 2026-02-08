extends Node

@export var weapon: Node3D
@export var state_chart: StateChart
@export var shoot: AudioStreamPlayer3D

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var ray: RayCast3D = $"../../../../MeshInstance3D/RayCast3D"

@export var bolt_add: PackedScene

func _on_shoot_state_entered() -> void:
	Global.player.camera.apply_shake()
	animation_player.play("shoot")
	shoot.play()
	var bolt = bolt_add.instantiate()
	get_tree().current_scene.add_child(bolt)
	bolt.source = Global.player
	var screen_center = get_viewport().size/2
	var origin = Global.player.camera.project_ray_origin(screen_center)
	var end = origin + Global.player.camera.project_ray_normal(screen_center) * 100
	ray.look_at(end)

	bolt.global_position = origin
	bolt.transform.basis = ray.global_transform.basis
	await animation_player.animation_finished
	state_chart.send_event("reload")


func _on_shoot_state_exited() -> void:
	pass # Replace with function body.


func _on_shoot_state_processing(delta: float) -> void:
	pass # Replace with function body.
