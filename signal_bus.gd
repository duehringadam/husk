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
signal update_interact_rect(aabb_3d: AABB)
signal npc_interacted(sheet_id: String)
signal dialogue_ended
signal dialogue_started
signal end_madtalk_dialogue_external
@warning_ignore_restore("unused_signal")
