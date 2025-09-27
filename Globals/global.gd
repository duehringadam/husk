extends Node

var debug
var player

enum INTERACT_TYPE {TALK,INSPECT,OPEN,CLOSE,ITEM,PICKUP}
enum STATUS_TYPE {BURNING,POISONED,SLEEP,BLEEDING}
var inventory: Array[item]

var camera_fov: int = 70
