class_name Weapon
extends Node3D

@export var two_handed: bool = false
@export var player_lookat_ray: RayCast3D
@export var hit_particles_add: PackedScene
@export var swing_sound: AudioStream
@export var hit_sound: AudioStream
@export var damage_component: DamageComponent
@export var blood_drip: GPUParticles3D
@export var bloodtimer: Timer
@export var blend_speed: int = 15

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_chart: StateChart = $StateChart


var can_attack: bool = true
var secondary_active_bool: bool = false

func _ready() -> void:
	state_chart.set_expression_property("can_attack", true)
	SignalBus.connect("secondary_active", secondary_active)
	SignalBus.connect("can_attack", can_attack_func)
	animation_player.play("equip")
	

func secondary_active(value:bool):
	secondary_active_bool = value
	
func can_attack_func(value: bool):
	can_attack = value

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
	pass

func _on_bloodtimer_timeout() -> void:
	blood_drip.emitting = false


func _on_damage_component_damage_dealt(amount: float, actual: float, target: hurtbox_component, type: int) -> void:
	
	var new_anim = animation_player.current_animation + "_hit"
	var anim_current_pos = animation_player.current_animation_position
	animation_player.play(new_anim)
	animation_player.seek(anim_current_pos)
	AudioManager.play_sound(hit_sound,self.global_position,-20)
	Global.player.camera.apply_shake(0.04)
	if !target.can_bleed:
		return
	var mesh_shader = mesh.get_active_material(0)
	mesh_shader.next_pass["shader_parameter/intensity"] = clampf(mesh_shader.next_pass["shader_parameter/intensity"]+.05,0,.5)
	if mesh_shader.next_pass["shader_parameter/intensity"] >= .2 && blood_drip != null:
		blood_drip.emitting = true
		bloodtimer.start()
	else:
		blood_drip.emitting = false
