extends Node3D

@export var weapon_initial_position: Vector3
@export var spell_projectile: PackedScene
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var target_ik_left: Node3D = $TargetIKLeft
@onready var firesfx: AudioStreamPlayer3D = $TargetIKLeft/GPUParticles3D/firesfx
@onready var animation_tree: AnimationTree = $AnimationTree

func _ready() -> void:
	self.position = weapon_initial_position
