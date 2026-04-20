extends Offhand

@onready var vfx_fire: Node3D = $VFX_fire_Constant_A3
@onready var damage_component: DamageComponent = $DamageComponent
@onready var firesfx: AudioStreamPlayer3D = $GPUParticles3D/firesfx
@onready var particles: GPUParticles3D = $GPUParticles3D

var is_active: bool = false

func activate():
	if !is_active:
		particles.local_coords = false
		SignalBus.emit_signal("raidal_blur", true)
		is_active = true
		damage_component.monitorable  = true
		damage_component.monitoring = true
		vfx_fire.activate()
		firesfx.play()


func deactivate():
	if is_active:
		vfx_fire.end()
		firesfx.stop()
		SignalBus.emit_signal("raidal_blur", false)
		is_active = false
		damage_component.monitorable  = false
		damage_component.monitoring = false
		particles.local_coords = true
