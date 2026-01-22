extends Area3D

signal aggro_changed(aggro_amount: float, aggro_position: Vector3)

@onready var raycasts: Node3D = $raycasts
@onready var raycast_look: Marker3D = $raycasts/raycast_look
@onready var aggrotimer: Timer = $aggrotimer

var aggro_amount := 0.0
var lose_aggro: bool = false
var has_player := false

func _on_timer_timeout() -> void:
		if has_player:
				var player_pos = Global.player.enemy_look_at.global_transform.origin
				raycasts.look_at(player_pos)
				
				for ray in raycasts.get_children():
					if ray is RayCast3D:
						ray.force_raycast_update()
						#ray.look_at(raycast_look.global_position)
						if ray.is_colliding():
							if ray.get_collider() is Player:
								aggro_amount = clampf(aggro_amount+.015,0,1.0)
								emit_signal("aggro_changed", aggro_amount, ray.get_collision_point())
								aggrotimer.start()

func _process(delta: float) -> void:
	if lose_aggro:
		aggro_amount -= clampf(aggro_amount-(2*delta),0,1.0)

func _on_aggrotimer_timeout() -> void:
	lose_aggro = true


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		has_player = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		has_player = false
