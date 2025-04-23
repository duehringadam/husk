extends Node

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"
@onready var state_chart: StateChart = $"../../.."
@export var damage_component: DamageComponent
@export var weapon: Node3D
@onready var gpu_trail: GPUTrail3D = $"../../../../MeshInstance3D/GPUTrail3D"

var camera
var viewport_camera

func _on_back_state_entered() -> void:
	animation_player.play("swing_back")
	gpu_trail.visible = true
	damage_component.monitorable = true
	damage_component.monitoring = true
	AudioManager.play_sound(weapon.swing_sound,weapon.global_position,0)
	await animation_player.animation_finished
	state_chart.send_event("idle")



func _on_back_state_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_back_state_exited() -> void:
	gpu_trail.visible = false
	damage_component.monitorable = false
	damage_component.monitoring = false
