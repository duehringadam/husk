extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var state_chart: StateChart = $"../../.."
@export var damage_component: DamageComponent
@export var weapon: Node3D
@onready var gpu_trail: GPUTrail3D = $"../../../../MeshInstance3D/GPUTrail3D"

var camera
var viewport_camera

func _on_forward_state_entered() -> void:
	camera = Global.player.camera
	viewport_camera = Global.player.viewport_camera
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"fov", camera.fov+5,.25)
	tween.tween_property(viewport_camera,"fov", camera.fov+5,.25)
	gpu_trail.visible = true
	damage_component.monitorable = true
	damage_component.monitoring = true
	animation_player.play("swing_forward",-1,.75)
	AudioManager.play_sound(weapon.swing_sound,weapon.global_position,-0)
	await animation_player.animation_finished
	state_chart.send_event("idle")



func _on_forward_state_exited() -> void:
	damage_component.monitorable = false
	damage_component.monitoring = false
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"fov", camera.fov-5,.25)
	tween.tween_property(viewport_camera,"fov", camera.fov-5,.25)


func _on_forward_state_processing(delta: float) -> void:
	pass # Replace with function body.
