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
@export var weapon_mesh: MeshInstance3D
@export var arm_mesh: MeshInstance3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_chart: StateChart = $StateChart


var can_attack: bool = true
var secondary_active_bool: bool = false
var timer = Timer.new()
var tween: Tween
func _ready() -> void:
	timer.wait_time = 5
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(remove_blood)
	state_chart.set_expression_property("can_attack", true)
	SignalBus.connect("secondary_active", secondary_active)
	SignalBus.connect("can_attack", can_attack_func)
	animation_player.play("equip")
	

func secondary_active(value:bool):
	secondary_active_bool = value
	
	if secondary_active_bool:
		state_chart.send_event("lower")
	else:
		state_chart.send_event("secondary_released")
	
func can_attack_func(value: bool):
	can_attack = value

func _on_damage_component_body_entered(body: Node3D) -> void:
	pass
	#AudioManager.play_sound(hit_sound,self.global_position,-20)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_primary") && can_attack && !secondary_active_bool:
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

func _process(delta: float) -> void:
	if timer.time_left > 0 && is_instance_valid(tween):
		tween.kill()

func _on_bloodtimer_timeout() -> void:
	blood_drip.emitting = false


func _on_damage_component_damage_dealt(types: Dictionary[DamageTypes.DAMAGE_TYPES, float], actual: float, target: hurtbox_component) -> void:
	timer.start()
	var new_anim = animation_player.current_animation #+ "_hit"
	var anim_current_pos = animation_player.current_animation_position
	animation_player.play(new_anim)
	animation_player.seek(anim_current_pos)
	AudioManager.play_sound(hit_sound,self.global_position,-20)
	Global.player.camera.apply_shake(0.04)
	if !target.can_bleed:
		return
		
	var weapon_mesh_shader = weapon_mesh.get_active_material(0)
	var arm_mesh_shader = arm_mesh.get_active_material(0)
	arm_mesh_shader.next_pass["shader_parameter/progress"] = clampf(weapon_mesh_shader.next_pass["shader_parameter/progress"]+.01,0,.5)
	weapon_mesh_shader.next_pass["shader_parameter/progress"] = clampf(weapon_mesh_shader.next_pass["shader_parameter/progress"]+.01,0,.5)
	if weapon_mesh_shader.next_pass["shader_parameter/progress"] >= .2 && blood_drip != null:
		blood_drip.emitting = true
		bloodtimer.start()
	else:
		blood_drip.emitting = false

func remove_blood():
	blood_drip.emitting = false
	var weapon_mesh_shader = weapon_mesh.get_active_material(0)
	var arm_mesh_shader = arm_mesh.get_active_material(0)
	tween = get_tree().create_tween()
	tween.tween_property(arm_mesh_shader.next_pass,"shader_parameter/progress",0,60)
	tween.tween_property(weapon_mesh_shader.next_pass,"shader_parameter/progress",0,60)
