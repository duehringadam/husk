class_name Weapon
extends Node3D

@export var player_lookat_ray: RayCast3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_chart: StateChart = $StateChart

var can_attack: bool = true


func _ready() -> void:
	state_chart.set_expression_property("can_attack", true)
