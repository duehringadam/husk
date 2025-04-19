class_name Weapon
extends Node3D

@export var two_handed: bool = false
@export var player_lookat_ray: RayCast3D
@export var hit_particles_add: PackedScene
@export var swing_sound: AudioStream
@export var hit_sound: AudioStream

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_chart: StateChart = $StateChart
@onready var blood_drip: GPUParticles3D = $"MeshInstance3D/blood drip"
@onready var bloodtimer: Timer = $bloodtimer


var can_attack: bool = true
var secondary_active_bool: bool = false

func _ready() -> void:
	state_chart.set_expression_property("can_attack", true)
	SignalBus.connect("secondary_active", secondary_active)
	animation_player.play("equip")

func secondary_active(value:bool):
	secondary_active_bool = value
	

func _on_damage_component_body_entered(body: Node3D) -> void:
	pass
	#AudioManager.play_sound(hit_sound,self.global_position,-20)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_primary") && can_attack:
		if Global.player.input_dir.x < 0 && Global.player.input_dir.y == 0:
			state_chart.send_event("hold_left")
		elif Global.player.input_dir.x > 0 && Global.player.input_dir.y == 0:
			state_chart.send_event("hold_right")
		if Global.player.input_dir.y < 0:
			state_chart.send_event("hold_forward")
		elif Global.player.input_dir.y > 0:
			state_chart.send_event("hold_back")
		
		elif Global.player.input_dir.x == 0 && Global.player.input_dir.y == 0:
			state_chart.send_event("hold_right")

func _on_damage_component_area_entered(area: Area3D) -> void:
	AudioManager.play_sound(hit_sound,self.global_position,-20)
	var mesh_shader = mesh.get_active_material(0)
	mesh_shader.next_pass["shader_parameter/intensity"] = clampf(mesh_shader.next_pass["shader_parameter/intensity"]+.05,0,.5)
	if mesh_shader.next_pass["shader_parameter/intensity"] >= .2:
		blood_drip.emitting = true
		bloodtimer.start()
	else:
		blood_drip.emitting = false

func _on_bloodtimer_timeout() -> void:
	blood_drip.emitting = false
