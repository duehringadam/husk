extends Node

signal camera_lock_requested(enable: bool)

func request_camera_lock(enable: bool) -> void:
	camera_lock_requested.emit(enable)


signal added_to_inventory(resource: Resource)
func add_to_inventory(resource: Resource) -> void:
	added_to_inventory.emit(resource)

signal sprint_disable_requested(enable: bool)

func request_sprint_lock(enable:bool) -> void:
	sprint_disable_requested.emit(enable)

signal slow_down_player(value: float)

func slow_player_requested(value:float):
	slow_down_player.emit(value)

signal move_disable(enable: bool)

func move_disable_requested(enable: bool):
	move_disable.emit(enable)
