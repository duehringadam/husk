extends Node


@warning_ignore("unused_signal")
signal player_immune(duration)
@warning_ignore("unused_signal")
signal dialogue_interact(dialogue: Array, duration: float, dialogue_sound: AudioStream, dialogue_position: Vector3)
@warning_ignore("unused_signal")
signal interact_close
@warning_ignore("unused_signal")
signal item_interact(item_pickup: item)
@warning_ignore("unused_signal")
signal can_attack(value: bool)
@warning_ignore("unused_signal")
signal secondary_active(value:bool)
@warning_ignore("unused_signal")
signal primary_active(value:bool)
@warning_ignore("unused_signal")
signal is_blocking(value:bool)
@warning_ignore("unused_signal")
signal status_ended(status: Global.STATUS_TYPE)
@warning_ignore("unused_signal")
signal telekinesis
@warning_ignore("unused_signal")
signal update_interact_rect(aabb_3d: AABB)
@warning_ignore("unused_signal")
signal npc_interacted(sheet_id: String)
@warning_ignore("unused_signal")
signal dialogue_ended(sheet_name: String, sequence_id: String)
@warning_ignore("unused_signal")
signal dialogue_started
