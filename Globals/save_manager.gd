extends Node

const LOCATION_SECTION = &'Location'
const INVENTORY_SECTION = &'Inventory'
const PLAYER_STATS_SECTION = &'Player_stats'
const ENEMY_LIST_SECTION = &'Enemy_list'
const WORLD_ITEMS_SECTION = &'World_Items_List'

#region Save Game
func save_game() -> void:
	save_position(Global.player.global_position)
	save_inventory(Global.player.inventory.inventory)
	save_player_stats(Global.player.player_stats)
	save_enemy_list(["lorem ipsum"])

func load_game() -> void:
	# Re write this later
	if SaveConfig.has_section(LOCATION_SECTION):
		Global.player.global_position = SaveConfig.get_config("Location", "Saved Position")
	else:
		save_position(Global.player.global_position)
	if SaveConfig.has_section(INVENTORY_SECTION):
		if SaveConfig.get_config(INVENTORY_SECTION, "Saved Inventory") != null:
			var inventory_list = SaveConfig.get_config("Inventory", "Saved Inventory")
			Global.player.inventory.reset_inventory(inventory_list)
	else:
		save_inventory(Global.player.inventory.inventory)
	if SaveConfig.has_section(PLAYER_STATS_SECTION):
		var stats = SaveConfig.get_config("Player_stats", "Saved Stats")
		Global.player.player_stats = stats
		SignalBus.emit_signal("player_stats_changed", stats)
		SignalBus.emit_signal("player_full_restore")
	else:
		save_player_stats(Global.player.player_stats)
#endregion

#region Location
func save_position(position_to_save: Vector3) -> void:
	SaveConfig.set_config(LOCATION_SECTION, "Saved Position", position_to_save)

func save_checkpoint(checkpoint: Checkpoint, default = null) -> void:
	SaveConfig.set_config(LOCATION_SECTION, "Current Checkpoint", checkpoint if checkpoint else default)

func get_checkpoint_from_config(checkpoint_location: String, default = null) -> Variant:
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

func save_inventory(inventory: Array) -> void:
	SaveConfig.set_config(INVENTORY_SECTION, "Saved Inventory", inventory)

func get_inventory_from_config(inventory_list: String, default = null) -> String:
	return SaveConfig.get_config(INVENTORY_SECTION, inventory_list, default)
#endregion

#region Player Stats
func save_player_stats(player_stats: Dictionary, default = null) -> void:
	SaveConfig.set_config(PLAYER_STATS_SECTION, "Saved Stats", player_stats if player_stats else default)
	
func get_player_stats_from_config(player_stats: String, default = null) -> String:
	return SaveConfig.get_config(PLAYER_STATS_SECTION, player_stats, default)
#endregion

#region Enemy List
func save_enemy_list(enemy_list: Array, default = null) -> void:
	return SaveConfig.set_config(ENEMY_LIST_SECTION, "Saved Enemies", enemy_list if enemy_list else default)

#func get_enemy_list_from_config(enemy_list: Array, default = null) -> String:
	#return SaveConfig.get_config(ENEMY_LIST_SECTION, enemy_list, default)
#endregion


#region World Items
func set_item_list(item_list: String, default = null)-> void:
	SaveConfig.set_config(WORLD_ITEMS_SECTION, item_list, default)

func get_item_list(item_list: String, default = null) -> Dictionary:
	if SaveConfig.has_section(item_list):
		return SaveConfig.get_config(WORLD_ITEMS_SECTION, item_list, default)
	else:
		var empty_dict: Dictionary[String, bool] = {} 
		return empty_dict
#endregion
