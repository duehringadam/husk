extends npc

@onready var chest_look_at: LookAtModifier3D = $merchant_animated/Armature/Skeleton/GeneralSkeleton/chestLookAt
@onready var look_at_head: LookAtModifier3D = $merchant_animated/Armature/Skeleton/GeneralSkeleton/headLookAt

@export var sheet_id: String

var is_talking: bool = false

func _ready() -> void:
	SignalBus.connect("dialogue_ended", dialogue_ended)

func dialogue_ended():
	is_talking = false
	look_at_head.target_node = ""

func _on_talk_on_complete(controller: InteractionController) -> void:
	if is_talking == false:
		is_talking = true
		animation_tree.set("parameters/conditions/stand_up", true)
		look_at_head.target_node = Global.player.head.get_path()
		SignalBus.emit_signal("npc_interacted", sheet_id)
		
