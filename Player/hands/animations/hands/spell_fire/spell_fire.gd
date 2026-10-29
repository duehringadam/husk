extends Offhand

@onready var vfx_fire: Node3D = $VFX_fire_Constant_A3
@onready var damage_component: DamageComponent = $DamageComponent
@onready var firesfx: AudioStreamPlayer3D = $Fire_03/firesfx
@onready var particles: GPUParticles3D = $Fire_03/Flame

var is_active: bool = false

func _ready() -> void:
	damage_component.source = Global.player

func activate():
	if !is_active:
		damage_component.source = Global.player
		particles.emitting = false
		is_active = true
		damage_component.monitorable  = true
		damage_component.monitoring = true
		vfx_fire.activate()
		firesfx.play()


func deactivate():
	if is_active:
		vfx_fire.end()
		firesfx.stop()
		is_active = false
		damage_component.monitorable  = false
		damage_component.monitoring = false
		particles.emitting = true
