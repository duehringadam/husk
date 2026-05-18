extends Node

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

func _ready() -> void:
	animation_tree["parameters/playback"].connect("state_finished", _anim_finished)

func _on_taunt_state_entered() -> void:
	source_npc.SPEED = 0
	#AudioManager.play_sound(load("res://sfx/zombie-death-2-95167.mp3"), source_npc.global_position,-1)
	animation_tree.set("parameters/conditions/aggro", true)

func _on_taunt_state_exited() -> void:
	pass # Replace with function body.


func _on_taunt_state_physics_processing(delta: float) -> void:
	pass
	#source_npc.rotation.y = lerp_angle(source_npc.rotation.y, atan2(source_npc.target.global_position.x, source_npc.target.global_position.z),10*delta)

func _anim_finished(state: StringName):
	if state == "taunt":
		animation_tree.set("parameters/conditions/aggro", false)
		state_chart.send_event("move")
