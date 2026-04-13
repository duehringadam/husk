extends Weapon

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("equip")

func block():
	animation_player.play("block")
