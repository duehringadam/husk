class_name Checkpoint
extends StaticBody3D


func _on_rest_on_complete(controller: InteractionController) -> void:
	Global.player.current_checkpoint = self
	SaveConfig.set_config("Location", "Saved Position", Global.player.global_position)
