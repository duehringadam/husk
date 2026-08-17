extends npc

@onready var interaction_collision: StaticBody3D = $interaction_collision

var is_talking: bool = false

func _ready() -> void:
	SignalBus.connect("dialogue_ended", dialogue_ended)
	SignalBus.connect("custom_effect", _npc_shop_open)

func dialogue_ended():
	interaction_collision.collision_layer = 8
	is_talking = false
	head_look_at.target_node = ""

func _on_talk_on_complete(controller: InteractionController) -> void:
	if is_talking == false:
		interaction_collision.collision_layer = 0
		is_talking = true
		animation_tree.set("parameters/conditions/stand_up", true)
		head_look_at.target_node = Global.player.head.get_path()
		SignalBus.emit_signal("npc_interacted", sheet_id)
		
