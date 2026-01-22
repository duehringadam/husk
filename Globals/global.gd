extends Node

var debug
var player

enum STATUS_TYPE {BURNING,POISONED,SLEEP,BLEEDING}
var inventory: Array[item]

var camera_fov: int = 70

var enemy_groups = 5
