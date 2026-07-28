class_name infestation_attach
extends BoneAttachment3D

signal spawn_enemy

@export var linear_force: float = 8.0
@export var target_bone: PhysicalBone3D
@export var health_component: HealthComponent
@export var blood_decal:PackedScene

@onready var blood_pos: RayCast3D = $blood_pos
@onready var infestation_animation: AnimationPlayer = $infestationAnimation
@onready var remote_transform: RemoteTransform3D = $RemoteTransform3D

var noise: FastNoiseLite = FastNoiseLite.new()
var has_activated: bool = false
var times_activated: int = 1

func _ready() -> void:
	if health_component:
		if !health_component.is_connected("died", start_infestation):
			health_component.connect("died", start_infestation)

	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.8 

func start_infestation():
	if !has_activated:
		has_activated = true
		infestation_animation.play("enemy_spawn_warning")

func _spawn_enemy():
	spawn_enemy.emit()
	
func trigger_twitch() -> void:
	if not target_bone:
		return
	if blood_pos.is_colliding():
		var blood_decal_add = blood_decal.instantiate()
		get_tree().current_scene.add_child(blood_decal_add)
		blood_decal_add.global_position = blood_pos.get_collision_point()
		
	var seed_time = Time.get_ticks_msec() * 0.001
	
	var lx = noise.get_noise_2d(seed_time, 0.0)
	var ly = noise.get_noise_2d(seed_time, 0.0)
	var lz = noise.get_noise_2d(seed_time, 0.0)
	
	var raw_vector = Vector3(lx, ly, lz).normalized()
	var linear_impulse = raw_vector * linear_force / target_bone.mass
	
	target_bone.apply_central_impulse(linear_impulse * times_activated)
	times_activated += 1


func _on_status_effect_component_status_activated(effects: Array[status_effect]) -> void:
	for i in effects:
		if i.effect_type == Global.STATUS_TYPE.BURNING:
			start_infestation()
