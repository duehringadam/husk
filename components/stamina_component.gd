class_name StaminaComponent
extends Node3D

signal max_stamina_changed(amount: float, new_value: float)
signal stamina_changed(amount: float, new_value: float)
signal died

@onready var player: Player = $".."

@export var player_stamina_scaling_curve: Curve
@export var max_stamina: float = 100.0
@export var stamina_regen_time: float = 1.0
@export var stamina_regen_rate: float = 1.0
@export var staming_cost_mult: float = 1.0

var current_stamina: float = max_stamina
var regen: bool = false
var timer = Timer.new()


func _ready() -> void:
	modify_max_stamina(max_stamina)
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(func(): regen = true)
	current_stamina = max_stamina
	emit_signal("max_stamina_changed", 0, max_stamina)
	emit_signal("stamina_changed", 0, current_stamina)
	

func modify_stamina(amount: float):
	current_stamina = clampf(current_stamina + amount, 0, max_stamina)
	emit_signal("stamina_changed", amount, current_stamina)
	if amount < 0:
		regen = false
		timer.start(stamina_regen_time)
		
	
func modify_max_stamina(amount: float):
	max_stamina += amount + player_stamina_scaling_curve.sample(player.player_stats[1]/100.0)+1
	emit_signal("max_stamina_changed", amount, max_stamina)


func _physics_process(delta: float) -> void:
	if regen:
		modify_stamina(stamina_regen_rate)
