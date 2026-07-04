class_name Checkpoint
extends StaticBody3D

@onready var checkpoint_respawn_point: Node3D = $checkpointRespawnPoint
@onready var overlaid_menu = $CheckpointScreen


#Inventory'
#const PLAYER_STATS_SECTION = &'Player_stats'
#const ENEMY_LIST_SECTION = &'Enemy_list'

func _on_rest_on_complete(_controller: InteractionController) -> void:
	overlaid_menu.visible = true
	overlaid_menu.process_mode = Node.PROCESS_MODE_INHERIT
	GamePiecesEventBus.emit_signal("camera_lock_requested", true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.player.can_attack = false
	Global.player.can_move = false
	SaveManager.save_game()
