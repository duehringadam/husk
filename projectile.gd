extends Node3D

@export var speed: int = 100

func _on_damage_component_area_entered(area: Area3D) -> void:
	pass


func _on_damage_component_body_entered(body: Node3D) -> void:
	pass

func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0,-speed*delta)
