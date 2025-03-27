extends ColorRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var hurtbox: hurtbox_component

func _ready() -> void:
	if !hurtbox.is_connected("damage_taken", _on_damage_taken):
		hurtbox.connect("damage_taken", _on_damage_taken)

func _on_damage_taken(amount: float, actual: float, source: DamageComponent):
	if amount > 0:
		animation_player.play("damage")
