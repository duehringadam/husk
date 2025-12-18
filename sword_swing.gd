extends Node

@export var state_chart: StateChart
@export var weapon: Node3D
@onready var animation_tree: AnimationTree = $"../../../../AnimationTree"




func _on_swing_left_state_entered() -> void:
	AudioManager.play_sound(weapon.swing_sound,weapon.global_position,0.0)
	animation_tree.set("parameters/conditions/swing", true)
	await animation_tree.animation_finished
	state_chart.send_event("idle")


func _on_swing_left_state_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(Global.player.camera,"fov", Global.camera_fov,.25)
	animation_tree.set("parameters/conditions/swing", false)


func _on_swing_left_state_processing(delta: float) -> void:
	pass # Replace with function body.
