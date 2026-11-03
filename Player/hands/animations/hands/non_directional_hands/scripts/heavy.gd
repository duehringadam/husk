extends Node

@export var state_chart: StateChart
@export var bone_attach: BoneAttachment3D
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var hand: Node3D

@onready var end_timer: Timer = $"../endTimer"

var weapon

func _on_heavy_swing_state_entered() -> void:
	Global.player.stamina_component.modify_stamina(-40)
	end_timer.start()


func _on_heavy_swing_state_exited() -> void:
	animation_tree.set("parameters/conditions/attack",false)


func _on_heavy_swing_state_input(event: InputEvent) -> void:
	pass # Replace with function body.


func _on_heavy_swing_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.


func _on_end_timer_timeout() -> void:
	var playback = animation_tree["parameters/playback"]
	playback.travel("idle")
	state_chart.send_event("idle")
