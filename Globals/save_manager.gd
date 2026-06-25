extends Node

const LOCATION_SECTION = &'Location'
const INVENTORY_SECTION = &'Inventory'
const PLAYER_STATS_SECTION = &'Player_stats'
const ENEMY_LIST_SECTION = &'Enemy_list'

#region Checkpoint
func set_checkpoint(checkpoint_location: String, default = null) -> void:
	SaveConfig.set_config(LOCATION_SECTION , checkpoint_location, default)

func get_checkpoint_from_config(checkpoint_location: String, default = null) -> String:
	return SaveConfig.get_config(LOCATION_SECTION , checkpoint_location, default)
#endregion

#region Inventory
func set_inventory():
	pass
	
func set_inventory_from_config():
	pass

func get_inventory_from_config():
	pass
#endregion

#region Player Stats
func set_player_stats():
	pass
	
func set_player_stats_from_config():
	pass

func get_player_stats_from_config():
	pass
#endregion

#region Enemy List
func set_enemy_list():
	pass
	
func set_enemy_list_from_config():
	pass

func get_enemy_list_from_config():
	pass
#endregion
