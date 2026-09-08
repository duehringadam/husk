class_name PinComponent
extends RayCast3D

@export var hurtbox: hurtbox_component
@export var stance_component: StanceComponent
var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.25
	timer.one_shot = true
	timer.timeout.connect(set_pin.bind(false))
	hurtbox.projectile_damage_taken.connect(set_pin.bind(true))

func set_pin(stance_damage: float, value: bool):
	if stance_damage > stance_component.max_stance/2:
		if value:
			timer.start()
			
		enabled = value
