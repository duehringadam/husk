extends Offhand

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var target_ik_left: Node3D = $TargetIKLeft
@onready var bloodanim: AnimationPlayer = $TargetIKLeft/VFX_BloodExplosion_O1/bloodanim
@onready var damage_component: DamageComponent = $TargetIKLeft/enemyDamage
@onready var ray: RayCast3D = $TargetIKLeft/RayCast3D
@onready var blood_marks: GPUParticles3D = $Blood_Marks_B5
@onready var splatter_2: GPUParticles3D = $splatter2
@onready var bloodsfx: AudioStreamPlayer3D = $TargetIKLeft/bloodsfx

var is_active: bool = false

func _ready() -> void:
	animation_player.play("spell_blood_idle")
	damage_component.source = Global.player

func activate():
	if !is_active:
		bloodanim.play("Init")
		animation_player.play("spell_blood_aoe")

func _process(delta: float) -> void:
	if ray.is_colliding():
		blood_marks.global_position = ray.get_collision_point()
		splatter_2.global_position = ray.get_collision_point()
