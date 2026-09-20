class_name WaterAreaComponent
extends Area3D

@export var slow_amount: int = 2

func _ready() -> void:
	if !self.has_meta("ground_type"):
		self.set_meta("ground_type", "water")
	if !body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if !body_exited.is_connected(_on_body_entered):
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.slow_speed = slow_amount


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		body.slow_speed = 0
