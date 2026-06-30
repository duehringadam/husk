class_name Checkpoint
extends StaticBody3D

#Inventory'
#const PLAYER_STATS_SECTION = &'Player_stats'
#const ENEMY_LIST_SECTION = &'Enemy_list'

func _on_rest_on_complete(controller: InteractionController) -> void:
	Global.player.current_checkpoint = self
	SaveManager.save_checkpoint(self)
	SaveManager.save_game()
	#SaveConfig.set_config("Location", "Saved Position", Global.player.global_position)
	#SaveConfig.set_config("Inventory", "Saved Inventory", Global.player.inventory.inventory)
	#SaveConfig.set_config("Player_stats", "Saved Stats", Global.player.player_stats)
	#SaveConfig.set_config("Enemy_list", "Saved Enemies", "lorem ipsum")
