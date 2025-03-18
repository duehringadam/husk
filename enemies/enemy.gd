extends CharacterBody3D

const SPEED = 2.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var los_area: Area3D = $LOSArea
@onready var vision_ray_cast: RayCast3D = %visionRayCast

var can_see_player = false
var alerted = false
var chasing = false

func _on_vision_timer_timeout() -> void:
	var overlaps = los_area.get_overlapping_bodies()
	
	if overlaps.size()>0:
		for i in overlaps:
			if i == Global.player:
				var playerPos = i.global_transform.origin
				vision_ray_cast.look_at(playerPos)
				vision_ray_cast.force_raycast_update()
				
				if vision_ray_cast.is_colliding():
					var collider = vision_ray_cast.get_collider()
					
					if collider == Global.player:
						can_see_player = true
						vision_ray_cast.debug_shape_custom_color = Color(174,0,0)
					else:
						vision_ray_cast.debug_shape_custom_color = Color(0,255,0)
						can_see_player = false
					
					
