class_name Projectile
extends Node3D

@export var speed: int = 100
@export var damage_component: DamageComponent
@export var ray_cast_3d: RayCast3D
@export var gpu_trail: GPUTrail3D
@export var lifetime: float = 10.0

var pin: bool = false
var timer = Timer.new()
var source: Node3D: set = _update_source

func _ready() -> void:
	add_child(timer)
	timer.wait_time = lifetime
	timer.start()
	timer.timeout.connect(func(): self.queue_free())

func _update_source(value: Node3D):
	source = value
	damage_component.source = source

func _on_damage_component_body_entered(body: Node3D) -> void:
	if body is StaticBody3D:
		gpu_trail.visible = false
		var collision_point = ray_cast_3d.get_collision_point()
		pin = true
		call_deferred("reparent",body)
		damage_component.set_deferred("monitorable", false)
		damage_component.set_deferred("monitoring", false)
		global_position = collision_point
	else:
		self.queue_free()

func _process(delta: float) -> void:
	if !pin:
		position += transform.basis * Vector3(0,0,-speed*delta)


func _on_damage_component_damage_dealt(types: Dictionary, actual: float, stance_damage: float, target: hurtbox_component) -> void:
	self.queue_free()
