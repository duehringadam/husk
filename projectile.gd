extends Node3D

@export var speed: int = 100
@onready var damage_component: DamageComponent = $MeshInstance3D/DamageComponent
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var gpu_trail: GPUTrail3D = $MeshInstance3D/GPUTrail3D

var pin: bool = false

func _on_damage_component_area_entered(area: Area3D) -> void:
	gpu_trail.visible = false
	var collision_point = ray_cast_3d.get_collision_point()
	pin = true
	call_deferred("reparent",area)
	damage_component.set_deferred("monitorable", false)
	damage_component.set_deferred("monitoring", false)
	global_position = collision_point


func _on_damage_component_body_entered(body: Node3D) -> void:
	pass

func _process(delta: float) -> void:
	if !pin:
		position += transform.basis * Vector3(0,0,-speed*delta)
