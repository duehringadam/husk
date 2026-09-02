extends Offhand

@onready var damage_component: DamageComponent = $DamageComponent
@onready var swing: AudioStreamPlayer3D = $swing
@onready var ambience: AudioStreamPlayer3D = $ambience
@onready var equip: AudioStreamPlayer3D = $equip

func _ready() -> void:
	equip.pitch_scale = randf_range(0.8,1.2)
	equip.play()
	damage_component.source = Global.player

func activate():
	damage_component.monitoring = true
	damage_component.monitorable = true
	swing.pitch_scale = randf_range(0.8,1.2)
	swing.play()

func deactivate():
	damage_component.monitoring = false
	damage_component.monitorable = false
