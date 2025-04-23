extends Node

@export var weapon: Node3D
@export var state_chart: StateChart
@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var ray: RayCast3D = $"../../../../MeshInstance3D/RayCast3D"


var bolt_add = preload("res://heavy_bolt.tscn")

func _on_shoot_state_entered() -> void:
	Global.player.camera.apply_shake()
	Global.player.viewport_camera.apply_shake()
	AudioManager.play_sound(weapon.swing_sound,weapon.global_position,-20.0)
	animation_player.play("shoot")
	
	var bolt = bolt_add.instantiate()
	get_tree().current_scene.add_child(bolt)
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
