extends Node

@export var state_chart: StateChart
@export var weapon: Node3D
@export var swing_audio: AudioStreamPlayer3D
@onready var animation_tree: AnimationTree = $"../../../../AnimationTree"

func _on_swing_left_state_entered() -> void:
	#if swing_audio:
		#swing_audio.play()
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov", Global.camera_fov,.25)
	get_tree().create_timer(1).timeout.connect(func(): state_chart.send_event("idle"))
	animation_tree.set("parameters/conditions/swing", true)
	await animation_tree.animation_finished
	state_chart.send_event("idle")
	

func _on_swing_left_state_exited() -> void:
	animation_tree.set("parameters/conditions/swing", false)


func _on_swing_left_state_processing(delta: float) -> void:
	pass # Replace with function body.
