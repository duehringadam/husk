extends Node

var debug
var player

enum INTERACT_TYPE {TALK,INSPECT,OPEN,CLOSE,PICKUP}

var inventory: Array[item]

var camera_fov: int = 70
