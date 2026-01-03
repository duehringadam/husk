
extends Node3D


@export var spell_projectile: PackedScene
@export var ray: RayCast3D
@export var throw_power_multiplier: float
@export var weapon_initial_position: Vector3

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spell_shapecast: ShapeCast3D = %spell_shapecast
@onready var state_chart: StateChart = $StateChart
@onready var spell_hold_sound: AudioStreamPlayer3D = $spell_hold_sound
@onready var hold_node: StaticBody3D = $holdNode
@onready var hold_joint: Generic6DOFJoint3D = %Generic6DOFJoint3D

var grabbed_object

func _ready() -> void:
	self.position = weapon_initial_position

func _input(event: InputEvent) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass
		
	
