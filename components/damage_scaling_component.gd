class_name damage_scaling_component
extends Node

var actual_damage_ratio: float = 0.0
var stored_damage_values: Array
var stored_stance_damage: float

var timer = Timer.new()
var swing_ended:= false

@export var damage_component: DamageComponent
@export var weapon_states: Array[StateChartState]
@export var end_swing: StateChartState


func _ready() -> void:
	add_child(timer)
	timer.wait_time = 1.25
	timer.one_shot = true
	stored_damage_values = damage_component.damage_types.values()
	stored_stance_damage = damage_component.stance_damage_value
	for i in weapon_states:
		if !i.state_entered.is_connected(hold_attack):
			i.state_entered.connect(hold_attack)
		if !i.state_exited.is_connected(attack):
			i.state_exited.connect(attack)
	if !end_swing.state_entered.is_connected(end_attack):
		end_swing.state_entered.connect(end_attack)
	
func hold_attack():
	SignalBus.emit_signal("weapon_charge_bool", true)
	swing_ended = false
	timer.start()
	
func attack():
	timer.stop()
	for i in damage_component.damage_types:
		damage_component.damage_types[i] *= actual_damage_ratio
	damage_component.stance_damage_value *= actual_damage_ratio

func end_attack():
	SignalBus.emit_signal("weapon_charge_bool", false)
	actual_damage_ratio = lerpf(actual_damage_ratio,0,.5)
	swing_ended = true
	for i in damage_component.damage_types:
		for v in stored_damage_values:
			damage_component.damage_types[i] = v
	damage_component.stance_damage_value = stored_stance_damage
	
func _process(delta: float) -> void:
	if swing_ended:
		actual_damage_ratio = 0
		SignalBus.emit_signal("weapon_charge_value", actual_damage_ratio)
	else:
		actual_damage_ratio = clampf(1.25-timer.time_left,.25,1.25)
		SignalBus.emit_signal("weapon_charge_value", actual_damage_ratio)
