extends Consumable
@onready var drink_sound: AudioStreamPlayer3D = $DrinkSound
@export var heal_amount: float = 15.0

func _ready() -> void:
	pass

func activate():
	drink_sound.play()
	Global.player.health_component.modify_health(heal_amount)
