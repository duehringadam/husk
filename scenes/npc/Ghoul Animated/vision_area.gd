extends Area3D

signal aggro_changed(aggro_amount: float, aggro_position: Node3D)
signal max_aggro(aggro_amount: float, aggro_position: Node3D)

@onready var raycasts: Node3D = $raycasts
@onready var raycast_look: Marker3D = $raycasts/raycast_look
@onready var aggrotimer: Timer = $aggrotimer

var aggro_amount := 0.0
var is_aggro: bool = false
var lose_aggro: bool = false
var has_player := false

func _on_timer_timeout() -> void:
		if has_player:
				var player_pos = Global.player.enemy_look_at.global_transform.origin
				raycasts.look_at(player_pos)
				
				for ray in raycasts.get_children():
					if ray is RayCast3D:
						await get_tree().physics_frame
						ray.force_raycast_update()
						ray.look_at(raycast_look.global_position)
						if ray.is_colliding():
							if ray.get_collider() is Player:
								aggro_amount = clampf(aggro_amount+.04,0,1.0)
								if aggro_amount != 1.0:
									emit_signal("aggro_changed", aggro_amount, ray.get_collider())
									aggrotimer.start()
								elif aggro_amount >= 1.0 && !is_aggro:
									is_aggro = true
									max_aggro.emit(aggro_amount, ray.get_collider())
								

func _process(delta: float) -> void:
	if lose_aggro:
		aggro_amount -= clampf(aggro_amount-(2*delta),0,1.0)

func _on_aggrotimer_timeout() -> void:
	lose_aggro = true
	is_aggro = false


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		has_player = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		has_player = false
