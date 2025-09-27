extends Node


signal player_immune(duration)
signal dialogue_interact(dialogue: Array, duration: float, dialogue_sound: AudioStream, dialogue_position: Vector3)
signal interact_close
signal item_interact(item_pickup: item)
signal can_attack(value: bool)
signal secondary_active(value:bool)
signal primary_active(value:bool)
signal is_blocking(value:bool)
signal status_ended(status: Global.STATUS_TYPE)
