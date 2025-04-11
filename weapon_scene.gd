class_name Weapon
extends Node3D

@export var player_lookat_ray: RayCast3D
@export var hit_particles_add: PackedScene
@export var swing_sound: AudioStream

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_chart: StateChart = $StateChart


var can_attack: bool = true


func _ready() -> void:
	state_chart.set_expression_property("can_attack", true)


func _on_damage_component_body_entered(body: Node3D) -> void:
	pass

	

func _on_damage_component_area_entered(area: Area3D) -> void:
	var mesh_shader = mesh.get_active_material(0)
	mesh_shader.next_pass["shader_parameter/intensity"] = clampf(mesh_shader.next_pass["shader_parameter/intensity"]+.05,0,.5)
		
