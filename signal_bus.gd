extends Node


signal player_immune(duration)
signal dialogue_interact(dialogue: Array, duration: float, dialogue_sound: AudioStream, dialogue_position: Vector3)
signal dialogue_close
signal can_attack(value: bool)
signal secondary_active(value:bool)
signal primary_active(value:bool)
signal is_blocking(value:bool)
