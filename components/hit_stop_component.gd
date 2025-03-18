class_name hitstop_component
extends Node

const HIT_STOP_TIME_SCALE: float = 0.05

@export var hurtbox_component: hurtbox_component
@export var hit_stop_duration: float = 1.0

func _ready():
	if !hurtbox_component.is_connected("damage_taken", _on_damage_taken):
		hurtbox_component.connect("damage_taken", _on_damage_taken)

func _on_damage_taken(incoming:float, reduced:float, source: DamageComponent):
	HitStop.hit_stop(HIT_STOP_TIME_SCALE, hit_stop_duration)
