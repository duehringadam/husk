class_name StanceComponent
extends Node

signal max_stance_changed(amount: float, new_value: float)
signal stance_changed(amount: float, new_value: float,source: DamageComponent)
signal stance_broken

@export var max_stance: float = 1.0
@export var stance_recharge_time := 2.0
var current_stance: float = max_stance
var timer: Timer = Timer.new()

func _ready() -> void:
	current_stance = max_stance
	emit_signal("max_stance_changed", 0.0, max_stance)
	emit_signal("stance_changed", 0.0, current_stance, null)
	add_child(timer)
	timer.wait_time = stance_recharge_time
	timer.one_shot = true
	timer.timeout.connect(reset_stance)

func modify_stance(amount: float, source: DamageComponent = null):
	timer.start()
	current_stance = clampf(current_stance + amount, 0.0, max_stance)
	emit_signal("stance_changed", amount, current_stance, source)
	
	if current_stance <= 0.0:
		reset_stance()
		emit_signal("stance_broken")
	
func modify_max_stance(amount: float):
	max_stance += amount
	modify_stance(max_stance)
	emit_signal("max_stance_changed", amount, max_stance)

func reset_stance():
	current_stance = clampf(max_stance, 0.0, max_stance)
