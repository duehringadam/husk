extends Node

@export var source_npc: CharacterBody3D
@export var state_chart: StateChart
@export var animation_tree: AnimationTree
@export var physical_bone_sim: PhysicalBoneSimulator3D
@onready var dead: AudioStreamPlayer3D = $"../../../../dead"

func _ready() -> void:
	animation_tree["parameters/playback"].connect("state_finished",_state_finished)
	
func _on_dead_state_entered() -> void:
	dead.play()
	if state_chart.get_expression_property("death_special"):
		animation_tree["parameters/playback"].travel("death_special")
	else:
		physical_bone_sim.influence = 1.0
		physical_bone_sim.active = true
		animation_tree.active = false
	SignalBus.emit_signal("enemy_currency_dropped", source_npc.currency_dropped)

func _state_finished(state: StringName):
	if state == "death_special":
		physical_bone_sim.physical_bones_start_simulation()
		physical_bone_sim.influence = 1.0
		physical_bone_sim.active = true
		animation_tree.active = false
