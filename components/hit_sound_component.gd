extends Node

@export var hurtbox_component: hurtbox_component
@export var hit_sound: AudioStream

func _ready():
	if !hurtbox_component.is_connected("damage_taken", _on_damage_taken):
		hurtbox_component.connect("damage_taken", _on_damage_taken)

func _on_damage_taken(incoming:float, reduced:float, source: DamageComponent):
	if source.hit_sound != null:
		AudioManager.play_sound(source.hit_sound, get_parent().global_position,-1.0)
	else:
		AudioManager.play_sound(hit_sound, get_parent().global_position,-1.0)
