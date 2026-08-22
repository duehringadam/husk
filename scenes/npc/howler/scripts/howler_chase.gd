extends Node

@export var patrol_speed: float = 3
@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

@onready var howl: AudioStreamPlayer3D = $"../../../../howl"

func _ready() -> void:
	animation_tree["parameters/playback"].connect("state_finished", _anim_finished)

func _on_howl_state_entered() -> void:
	state_chart.set_expression_property("has_howled", true)
	howl.play()
	animation_tree["parameters/playback"].travel("howl")
	source_npc.SPEED = 0


func _on_howl_state_exited() -> void:
	SignalBus.emit_signal("raidal_blur", false)


func _on_howl_state_physics_processing(delta: float) -> void:
	source_npc.rotation.y = lerp_angle(source_npc.rotation.y, atan2(source_npc.direction.x, source_npc.direction.z),10*delta)

func _anim_finished(state: StringName):
	if state == "howl":
		state_chart.send_event("run_away")
