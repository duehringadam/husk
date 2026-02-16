class_name hitstop_component
extends Node

const HIT_STOP_TIME_SCALE: float = 0.05

@export var hurtbox_component: hurtbox_component
@export var health_component: HealthComponent
@export var hit_stop_duration: float = .15
@export var priority: int = 1

func _ready():
	if hurtbox_component != null:
		if !hurtbox_component.is_connected("damage_taken", _on_damage_taken):
			hurtbox_component.connect("damage_taken", _on_damage_taken)
	if health_component != null:
		if !health_component.is_connected("health_changed", _on_health_changed):
			health_component.connect("health_changed", _on_health_changed)	

func _on_damage_taken(reduced:float, source: DamageComponent, hit_dir: Vector3):
	if reduced > 1:
		HitStop.hit_stop(HIT_STOP_TIME_SCALE, hit_stop_duration, priority)

func _on_health_changed(amount: float, new_value: float):
	if !is_instance_valid(health_component.damage_source): return
	if abs(amount) > 1:
		if is_instance_valid(health_component):
			if health_component.damage_source is Player:
				HitStop.hit_stop(HIT_STOP_TIME_SCALE, hit_stop_duration, priority)
