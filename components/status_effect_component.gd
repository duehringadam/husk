class_name status_effect_component
extends Node

signal status_applied(status_effect: DamageTypes.STATUS_EFFECTS, application_amount: float)

@export var status_effect: DamageTypes.STATUS_EFFECTS

@export var application_amount: float = 0.0


## Override this to customize damage behavior (scale with velocity, etc)
func apply_status(target: hurtbox_component):
	emit_signal("status_applied", status_effect, application_amount)
	return application_amount
