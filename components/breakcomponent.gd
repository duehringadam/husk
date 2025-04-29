class_name PhysicsBreakComponent

extends Node3D

@export var PhysicsObjectArray: Array[RigidBody3D]
@export var health_component: HealthComponent
@export var hurtboxcomponent : hurtbox_component

func _ready() -> void:
	if health_component != null:
		if !health_component.is_connected("died", _on_broken):
			health_component.connect("died", _on_broken)
			
func _on_broken():
	var player_dir = global_position.direction_to(Global.player.global_position)
	hurtboxcomponent.monitoring = false
	hurtboxcomponent.monitorable = false
	for i in PhysicsObjectArray:
		i.freeze = false
		i.linear_velocity -= player_dir*4
		i.collision_layer = 1
	await get_tree().create_timer(5).timeout.connect(func(): queue_free())
