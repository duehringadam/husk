extends Node3D


@export var throw_power_multiplier: float

@onready var spell_shapecast: ShapeCast3D = %spell_shapecast
@onready var spell_hold_sound: AudioStreamPlayer3D = $spell_hold_sound
@onready var hold_node: StaticBody3D = $holdspot
@onready var state_chart: StateChart = $StateChart
@onready var spell_cast_sound: AudioStreamPlayer3D = $spell_cast_sound

var grabbed_object
var is_active: bool = false

func _ready() -> void:
	pass
	
func activate():
	if !is_active:
		is_active = true
		spell_cast_sound.playing =  true

func deactivate():
	if is_active:
		is_active = false
	
