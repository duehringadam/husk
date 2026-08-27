extends Node

var debug
var player

enum STATUS_TYPE {BURNING,POISONED,SLEEP,BLEEDING,LEPROSY}

var camera_fov: int = 70

var enemy_groups = 5

var non_respawnable_items: Dictionary[String, bool]:
	set(dict):
		SaveManager.set_item_list("Non-Respawnable Items", dict)
		
var non_respawnable_npcs: Dictionary
