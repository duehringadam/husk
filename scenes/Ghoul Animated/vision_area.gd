extends Area3D

signal aggro

@export var beehave: BeehaveTree

@onready var raycasts: Node3D = $raycasts

@onready var raycast_look: Marker3D = $raycasts/raycast_look

var vision_rays_colliding := 0
var aggro_amount := 0.0
var lose_aggro: bool = false

func _on_timer_timeout() -> void:
	var overlaps = get_overlapping_bodies()
	if overlaps.size() > 0:
		for i in overlaps:
			if i is Player:
				var player_pos = i.head.global_transform.origin
				raycasts.look_at(player_pos)
				
				for ray in raycasts.get_children():
					if ray is RayCast3D:
						ray.force_raycast_update()
						ray.look_at(raycast_look.global_position)
						if ray.is_colliding():
							if ray.get_collider() is Player:
								aggro_amount = clampf(aggro_amount+.06,0,1.0)
								
	if aggro_amount >= 1.0:
		
		beehave.blackboard.set_value("aggro", true)

func _process(delta: float) -> void:
	if lose_aggro:
		aggro_amount -= 2*delta
		print(aggro_amount)

func _on_aggrotimer_timeout() -> void:
	lose_aggro = true
