class_name hurtbox_component
extends Area3D

signal damage_taken(actual: float, source: DamageComponent, hit_dir: Vector3)
signal apply_statuses(status_types: Global.STATUS_TYPE, application_amount: float)

@onready var timer: Timer

@export var hurtboxes_to_disable: Array[hurtbox_component]

## Reduction on incoming damage. Zero takes full damage, one takes none. For more complex behavior, override [method reduce_damage]
@export var damage_resistances: Dictionary[DamageTypes.DAMAGE_TYPES, float]
@export var damage_weakness: Dictionary[DamageTypes.DAMAGE_TYPES, float]
@export var status_resistances: Dictionary[Global.STATUS_TYPE, float]
@export var status_weaknesses: Dictionary[Global.STATUS_TYPE, float]

## Where to apply incoming damage
@export var health_component: HealthComponent
@export var bone_health_component: BoneHealthComponent
@export var status_component: status_effect_component
@export var stance_component: StanceComponent
@export var invulnerability_duration: float
@export var damage_particles: PackedScene
@export var hit_sound: AudioStream
@export var can_bleed: bool = false
@export var source: Node3D

## add the invulnerability timer
func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	SignalBus.connect("player_immune",invulnerability)
	
## start the invulnerability timer
func invulnerability(duration: float):
	timer.start(duration)
	if hurtboxes_to_disable:
		for i in hurtboxes_to_disable:
			i.timer.start(i.duration)

## Override this to cusomize damage reduction (damage types, armor, etc)
func modify_damage(damage_type: DamageTypes.DAMAGE_TYPES, amount: float, source: DamageComponent) -> float:
	if damage_resistances.keys().has(damage_type):
		return amount * (1 - damage_resistances[damage_type])
	if damage_weakness.keys().has(damage_type):
		return amount * (1 + damage_weakness[damage_type])
	else:
		return amount

func apply_status(status_types: Dictionary[Global.STATUS_TYPE, float]):
	for i in status_types:
		if status_resistances.keys().has(i):
			emit_signal("apply_statuses", [i],(1-status_resistances[i]))
		if status_weaknesses.keys().has(i):
			emit_signal("apply_statuses", i,(1*status_weaknesses[i]))

func take_damage(damage_types: Dictionary[DamageTypes.DAMAGE_TYPES, float], status_types: Dictionary[Global.STATUS_TYPE, float], stance_damage: float, source: DamageComponent):
	var hit_dir = (global_position.direction_to(source.global_position)).normalized()
	if timer.time_left > 0: return 0
	# invulnerability on damage.
	invulnerability(invulnerability_duration)
	# take damage
	var sum := 0.0
	for i in damage_types:
			var actual = modify_damage(i,damage_types[i], source)
			if status_types.size() != 0:
				apply_status(status_types)
			emit_signal("damage_taken", actual, source, hit_dir)
			if health_component:
				health_component.modify_health(-actual)
			if bone_health_component:
				bone_health_component.modify_health(-actual)
				if damage_types.keys().has(DamageTypes.DAMAGE_TYPES.STRIKE):
					bone_health_component.last_damage_taken = DamageTypes.DAMAGE_TYPES.STRIKE
				if damage_types.keys().has(DamageTypes.DAMAGE_TYPES.SLASH):
					bone_health_component.last_damage_taken = DamageTypes.DAMAGE_TYPES.SLASH
			sum += actual
	if stance_component != null:
		stance_component.modify_stance(-stance_damage)
	if hit_sound != null:
		AudioManager.play_sound(hit_sound,self.global_position,-10.0)
	return sum
