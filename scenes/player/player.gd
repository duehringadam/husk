@tool 
extends Player

@onready var _interaction_controller: RayCast3DInteractionController = $Head/Neck/Camera3D/RayCast3D/RayCast3DInteractionController
@onready var hold_joint: Generic6DOFJoint3D = $Head/Neck/Camera3D/RayCast3D/RayCast3DInteractionController/Generic6DOFJoint3D

var blocking:= false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	Global.player = self
	if Engine.is_editor_hint(): return
	GamePiecesEventBus.camera_lock_requested.connect(_on_camera_lock_requested)


func _on_camera_lock_requested(enable: bool) -> void:
	lock_camera = enable
