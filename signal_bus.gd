extends Node


@warning_ignore_start("unused_signal")
signal player_immune(duration)
signal dialogue_interact(dialogue: Array, duration: float, dialogue_sound: AudioStream, dialogue_position: Vector3)
signal interact_close
signal item_interact(item_pickup: item) 
signal can_attack(value: bool)
signal secondary_active(value:bool)
signal primary_active(value:bool)
signal kick_active(value:bool)
signal is_blocking(value:bool)
signal block_amount(value:float)
signal status_ended(status: Global.STATUS_TYPE)
signal telekinesis
signal hide_interact_rect()
signal npc_interacted(sheet_id: String)
signal dialogue_ended
signal dialogue_started
signal end_madtalk_dialogue_external
signal weapon_charge_value(value: float)
signal weapon_charge_bool(value: bool)
@warning_ignore_restore("unused_signal")
