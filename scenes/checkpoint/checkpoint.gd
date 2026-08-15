class_name Checkpoint
extends StaticBody3D

@onready var checkpoint_respawn_point: Node3D = $checkpointRespawnPoint
@onready var overlaid_menu = $CheckpointScreen

var checkpoint_id: String = ""

func _ready() -> void:
	var scene_file = owner.scene_file_path if owner else "global"
	
	var node_path = self.get_path()
	
	checkpoint_id = scene_file + "::" + str(node_path)

func _on_rest_on_complete(controller: InteractionController) -> void:
	overlaid_menu.visible = true
	overlaid_menu.process_mode = Node.PROCESS_MODE_INHERIT
	GamePiecesEventBus.emit_signal("camera_lock_requested", true)
	SignalBus.emit_signal("player_full_restore")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.player.can_attack = false
	Global.player.can_move = false
	Global.player.can_jump = false
	SaveConfig.set_config("Location", "Saved Checkpoint", checkpoint_id)
	SaveConfig.set_config("Player_stats", "Saved Stats", Global.player.player_stats)
	SaveConfig.set_config("Enemy_list", "Saved Enemies", "lorem ipsum")
