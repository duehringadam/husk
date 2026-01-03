@tool 
extends Player

@onready var _interaction_controller: RayCast3DInteractionController = $Head/Neck/Camera3D/RayCast3D/RayCast3DInteractionController
@onready var hold_joint: Generic6DOFJoint3D = $Head/Neck/Camera3D/RayCast3D/RayCast3DInteractionController/Generic6DOFJoint3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	Global.player = self
	if Engine.is_editor_hint(): return
	GamePiecesEventBus.camera_lock_requested.connect(_on_camera_lock_requested)
	GamePiecesEventBus.sprint_disable_requested.connect(_on_sprint_disable_requested)
	GamePiecesEventBus.slow_down_player.connect(_on_slow_player)
	GamePiecesEventBus.move_disable.connect(_on_move_disabled)

func _on_move_disabled(enable: bool):
	can_move = enable

func _on_camera_lock_requested(enable: bool) -> void:
	lock_camera = enable

func _on_sprint_disable_requested(enable: bool) -> void:
	disable_sprint = enable

func _on_slow_player(value: float):
	walk_speed -= value
	sprint_speed -= value
