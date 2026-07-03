extends Node

const LOCATION_SECTION = &'Location'
const INVENTORY_SECTION = &'Inventory'
const PLAYER_STATS_SECTION = &'Player_stats'
const ENEMY_LIST_SECTION = &'Enemy_list'
const WORLD_ITEMS_SECTION = &'World_Items_List'

#region Checkpoint
func set_checkpoint(checkpoint_location: String, default = null) -> void:
	SaveConfig.set_config(LOCATION_SECTION, checkpoint_location, default)

func get_checkpoint_from_config(checkpoint_location: String, default = null) -> Vector3:
	return SaveConfig.get_config(LOCATION_SECTION, checkpoint_location, default)
#endregion

#region Player saved position
func set_player_saved_position(saved_position: String, default = null)->void:
	SaveConfig.set_config(LOCATION_SECTION, saved_position, default)

func get_player_saved_position(saved_position: String, default = null) -> Vector3:
	return SaveConfig.get_config(LOCATION_SECTION, saved_position, default)
#endregion

#region Inventory
func set_inventory(inventory_list: String, default = null) -> void:
	SaveConfig.set_config(INVENTORY_SECTION, inventory_list, default)
	
func get_inventory_from_config(inventory_list: String, default = null) -> String:
	return SaveConfig.get_config(INVENTORY_SECTION, inventory_list, default)
#endregion

#region Player Stats
func set_player_stats(player_stats: String, default = null) -> void:
	return SaveConfig.set_config(PLAYER_STATS_SECTION, player_stats, default)


func get_player_stats_from_config(player_stats: String, default = null) -> String:
	return SaveConfig.get_config(PLAYER_STATS_SECTION, player_stats, default)
#endregion

#region Enemy List
func set_enemy_list(enemy_list: String, default = null) -> void:
	return SaveConfig.set_config(ENEMY_LIST_SECTION, enemy_list, default)
	
#func set_enemy_list_from_config():
	#pass

func get_enemy_list_from_config(enemy_list: String, default = null) -> String:
	return SaveConfig.get_config(ENEMY_LIST_SECTION, enemy_list, default)
#endregion


#region World Items
func set_item_list(item_list: String, default = null)-> void:
	SaveConfig.set_config(WORLD_ITEMS_SECTION, item_list, default)

func get_item_list(item_list: String, default = null) -> Dictionary:
	return SaveConfig.get_config(WORLD_ITEMS_SECTION, item_list, default)
#endregion
