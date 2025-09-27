extends ColorRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var hurtbox: hurtbox_component

func _ready() -> void:
	if !hurtbox.is_connected("damage_taken", _on_hurtbox_component_damage_taken):
		hurtbox.connect("damage_taken", _on_hurtbox_component_damage_taken)

func _on_hurtbox_component_damage_taken(actual: float, source: DamageComponent, hit_dir: Vector3) -> void:
	if actual > 0:
		animation_player.play("damage")
