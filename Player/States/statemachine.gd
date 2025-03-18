extends Node

class_name StateMachine

@export var CURRENT_STATE: State
@onready var state_label: Label = %Label
var new_state

var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition)
		else:
			push_warning("State machine contains incompatible node")
	CURRENT_STATE.enter(null)

func _process(delta: float) -> void:
	CURRENT_STATE.update(delta)
	state_label.text = str(CURRENT_STATE)

func _physics_process(delta: float) -> void:
	CURRENT_STATE.physics_update(delta)
	
func on_child_transition(new_state_name: StringName)->void:
	new_state = states.get(new_state_name)
	if new_state != null:
		if new_state != CURRENT_STATE:
			CURRENT_STATE.exit()
			new_state.enter(CURRENT_STATE)
			CURRENT_STATE = new_state
	else:
		push_warning("State does not exist")


func _on_animation_player_current_animation_changed(name: String) -> void:
	if new_state != null:
		if new_state != CURRENT_STATE:
			CURRENT_STATE.exit()
			new_state.enter(CURRENT_STATE)
			CURRENT_STATE = new_state
