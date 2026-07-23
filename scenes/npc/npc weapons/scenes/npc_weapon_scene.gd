class_name npc_weapon_scene
extends Node3D

@export var damage_component: DamageComponent


func activate():
	damage_component.monitorable = true
	damage_component.monitoring = true

func deactivate():
	damage_component.monitorable = false
	damage_component.monitoring = false
