extends Weapon

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	self.position = weapon_initial_position
	SignalBus.connect("npc_interacted", _on_npc_interacted)
	SignalBus.connect("dialogue_ended", _on_dialogue_ended)
	animation_player.play("equip")

func block():
	animation_player.play("block")
