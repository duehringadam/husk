class_name Checkpoint
extends StaticBody3D


func _on_rest_on_complete(controller: InteractionController) -> void:
	Global.player.current_checkpoint = self
