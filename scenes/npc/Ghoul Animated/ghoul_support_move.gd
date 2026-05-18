extends Node

@export var patrol_speed: float = 3
@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

@export var swing_cooldown: float

var delta_timer: float
var timer = Timer.new()

func _ready() -> void:
	self.add_child(timer)
	timer.wait_time = swing_cooldown
	timer.one_shot = true


func _on_move_state_entered() -> void:
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/walk", true)
	animation_tree.set("parameters/conditions/chargeRight", false)
	animation_tree.set("parameters/conditions/chargeLeft", false)
	source_npc.SPEED = patrol_speed


func _on_move_state_exited() -> void:
	pass # Replace with function body.


func _on_move_state_physics_processing(delta: float) -> void:
		source_npc.rotation.y = lerp_angle(source_npc.rotation.y, atan2(source_npc.direction.x, source_npc.direction.z),10*delta)
		var current_location = source_npc.global_position
		var desired_location = source_npc.navigation_agent.get_next_path_position()
		var new_velocity = (desired_location - current_location).normalized() * source_npc.SPEED
		source_npc.navigation_agent.set_velocity(new_velocity)
		
		if source_npc.target:
			var random_pos = NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().navigation_map,source_npc.target.global_position)
			source_npc.navigation_agent.set_target_position(source_npc.target.global_position)
			source_npc.search_position = random_pos
			if !source_npc.navigation_agent.is_target_reachable():
				source_npc.target = null
				state_chart.send_event("idle")
		else:
			var random_pos = NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().navigation_map,Global.player.global_position)
			source_npc.navigation_agent.set_target_position(Global.player.global_position)
			source_npc.search_position = random_pos
			if !source_npc.navigation_agent.is_target_reachable():
				source_npc.target = null
				state_chart.send_event("idle")
		
		if timer.time_left <= 0:
			if source_npc.target:
				if source_npc.global_position.distance_to(source_npc.target.global_position) < 2:
					timer.start()
					state_chart.send_event("charge")
		
		if source_npc.target:
			if source_npc.global_position.distance_to(source_npc.target.global_position) > 1.5:
				source_npc.SPEED = 3
				animation_tree.set("parameters/conditions/run", true)
				animation_tree.set("parameters/conditions/walk", false)
			else:
				source_npc.SPEED = 2
				animation_tree.set("parameters/conditions/run", false)
				animation_tree.set("parameters/conditions/walk", true)
		
