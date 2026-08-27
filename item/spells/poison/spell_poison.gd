extends Offhand

@onready var vfx_poison: Node3D = $VFX_PoisonLiquidFountain2
@onready var damage_component: DamageComponent = $DamageComponent
@onready var poison_spray: AudioStreamPlayer3D = $GPUParticles3D/poison_spray
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var vfx_poison_anim: AnimationPlayer = $VFX_PoisonLiquidFountain2/AnimationPlayer
@onready var poison_cloud_creation_timer: Timer = $poisonCloudCreationTimer
@onready var poison_cloud_ray: RayCast3D = $poisonCloudRay
@onready var fallback_cloud_pos: Node3D = $poisonCloudRay/fallbackCloudPos


var poison_cloud_add = preload("res://item/spells/poison/poison_cloud.tscn")

var is_active: bool = false

func _ready() -> void:
	poison_cloud_creation_timer.timeout.connect(create_cloud)

func activate():
	if !is_active:
		particles.local_coords = false
		is_active = true
		damage_component.monitorable  = true
		damage_component.monitoring = true
		vfx_poison_anim.play("Init")
		poison_spray.play()
		poison_cloud_creation_timer.start()


func deactivate():
	if is_active:
		poison_cloud_creation_timer.stop()
		vfx_poison_anim.play("End")
		poison_spray.stop()
		is_active = false
		damage_component.monitorable  = false
		damage_component.monitoring = false
		particles.local_coords = true


func create_cloud():
	var poison_cloud = poison_cloud_add.instantiate()
	get_tree().current_scene.add_child(poison_cloud)
	if poison_cloud_ray.is_colliding():
		poison_cloud.global_position = poison_cloud_ray.get_collision_point()
	else:
		poison_cloud.global_position = fallback_cloud_pos.global_position
