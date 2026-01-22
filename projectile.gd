class_name Projectile
extends Node3D

@export var speed: int = 100
@export var damage_component: DamageComponent
@export var ray_cast_3d: RayCast3D
@export var gpu_trail: GPUTrail3D
@export var lifetime: float = 10.0

var pin: bool = false
var timer = Timer.new()

func _ready() -> void:
	add_child(timer)
	timer.wait_time = lifetime
	timer.start()
	timer.timeout.connect(func(): self.queue_free())

func _on_damage_component_area_entered(area: Area3D) -> void:
	gpu_trail.visible = false
	var collision_point = ray_cast_3d.get_collision_point()
	pin = true
	call_deferred("reparent",area)
	damage_component.set_deferred("monitorable", false)
	damage_component.set_deferred("monitoring", false)
	global_position = collision_point


func _on_damage_component_body_entered(body: Node3D) -> void:
	gpu_trail.visible = false
	var collision_point = ray_cast_3d.get_collision_point()
	pin = true
	#call_deferred("reparent",body)
	damage_component.set_deferred("monitorable", false)
	damage_component.set_deferred("monitoring", false)
	global_position = collision_point

func _process(delta: float) -> void:
	if !pin:
		position += transform.basis * Vector3(0,0,-speed*delta)
