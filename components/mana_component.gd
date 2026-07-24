class_name ManaComponent
extends Node3D

signal max_mana_changed(amount: float, new_value: float)
signal mana_changed(amount: float, new_value: float)

@export var max_mana: float
@export var base_mana: float = 50
var current_mana: float = max_mana

var damage_source: Node3D

func _ready() -> void:
	current_mana = max_mana
	emit_signal("max_mana_changed", 0, max_mana)
	emit_signal("mana_changed", 0, current_mana)
	SignalBus.emit_signal("player_current_mana_changed", current_mana)
	SignalBus.emit_signal("player_max_mana_changed", max_mana)
	SignalBus.connect("player_stats_changed", func(_stats: Dictionary):set_max_mana(base_mana))
	SignalBus.connect("player_full_restore", func():set_current_mana(max_mana))

func modify_mana(amount: float):
	current_mana = clampf(current_mana + amount, 0, max_mana)
	emit_signal("mana_changed", amount, current_mana)
	if current_mana <= 0:
		emit_signal("died")
	
func modify_max_mana(amount: float):
	max_mana += amount
	modify_mana(max_mana)
	emit_signal("max_mana_changed", amount, max_mana)

func set_max_mana(amount:float):
	max_mana = amount
	emit_signal("max_mana_changed", amount, max_mana)

func set_current_mana(amount:float):
	current_mana = clampf(amount, 0, max_mana)
	emit_signal("mana_changed", amount, current_mana)
