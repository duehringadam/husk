class_name interact
extends Area3D

@export var interact_type: Global.INTERACT_TYPE

## The VisualInstance3D (or parent of one or more) that will be
## used to place the interact frame
@export var visual_root: Node3D

func _on_body_entered(body: Node3D) -> void:
	pass


func _input(event: InputEvent) -> void:
	pass


func _on_body_exited(body: Node3D) -> void:
	pass
