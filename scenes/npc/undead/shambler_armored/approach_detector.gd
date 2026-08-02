class_name ApproachDetector
extends Node

signal rapid_approach_detected
signal approach_ended

@export var enemy: npc
@export var approach_speed_threshold: float = 8.0
@export var detection_range: float = 15.0
@export var direct_approach_threshold: float = 0.7

var player: Player

var _is_approaching: bool = false

func _ready() -> void:
	player= Global.player

func _physics_process(delta: float) -> void:
	if not player or not enemy:
		return
		
	var was_approaching = _is_approaching
	
	_is_approaching = check_rapid_approach()
	
	if _is_approaching and not was_approaching:
		rapid_approach_detected.emit()
	elif not _is_approaching and was_approaching:
		approach_ended.emit()
		

func check_rapid_approach() -> bool:
	var to_enemy = enemy.global_position - player.global_position
	var distance = to_enemy.length()
	
	if distance > detection_range:
		return false
		
	var player_speed = player.velocity.length()
	if player_speed <= approach_speed_threshold:
		return false
	
	var dir_to_enemy = to_enemy.normalized()
	var approach_dot = player.velocity.normalized().dot(dir_to_enemy)
	
	return approach_dot > direct_approach_threshold
