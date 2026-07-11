extends Node

@export var circle_speed: float = 3.0
@export var ideal_distance: float = 4.0
@export var minimum_circle_time: float = 1.0
@export var maximum_circle_time: float = 3.0
@export var attack_chance: float = 0.3

@export var source_npc: npc
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

@onready var circle_timer: Timer = %circleTimer

var target: Node3D
var circle_dir: int = 1
var target_circle_time: float

func _on_circle_around_state_entered() -> void:
	target = source_npc.target
	circle_dir = 1 if randf() > 0.5 else -1
	target_circle_time = randf_range(minimum_circle_time, maximum_circle_time)
	circle_timer.wait_time = maximum_circle_time
	circle_timer.start()
	source_npc.SPEED = circle_speed
	animation_tree["parameters/walkBlendSpace/blend_position"].y = 0.0
	
func _on_circle_around_state_exited() -> void:
	pass # Replace with function body.


func _on_circle_around_state_physics_processing(delta: float) -> void:
	animation_tree["parameters/walkBlendSpace/blend_position"].x = lerpf(animation_tree["parameters/walkBlendSpace/blend_position"].x, circle_dir, delta*10)
	if not target or not is_instance_valid(target):
		state_chart.send_event("idle")
	
	var to_player = (target.global_position - source_npc.global_position)
	var distance = to_player.length()
	to_player = to_player.normalized()
	
	var strafe_dir = to_player.cross(Vector3.UP).normalized()
	strafe_dir *= circle_dir
	
	var difference = distance - ideal_distance
	var approach_dir = to_player * sign(difference) * 0.3
	
	var move_dir = (strafe_dir + approach_dir).normalized()
	
	var current_location = source_npc.global_position
	var desired_location = source_npc.navigation_agent.get_next_path_position()
	var new_velocity = (desired_location - current_location).normalized() * circle_speed
	source_npc.navigation_agent.set_velocity(new_velocity)
	var circle_pos = NavigationServer3D.map_get_closest_point(get_tree().current_scene.get_world_3d().get_navigation_map(), source_npc.global_position + (move_dir * circle_speed))
	source_npc.navigation_agent.set_target_position(circle_pos)
	face_target(delta)

func face_target(delta: float):
	var target_dir = (source_npc.target.global_position - source_npc.global_position).normalized()
	source_npc.rotation.y = lerp_angle(source_npc.rotation.y, atan2(target_dir.x, target_dir.z),10*delta)

func roll_attack_chance():
		if randf() < attack_chance:
			state_chart.send_event("attack")
		else:
			circle_timer.start()
			circle_timer.wait_time = randf_range(minimum_circle_time, maximum_circle_time)
			if randf() > 0.3:
				circle_dir *= -1
