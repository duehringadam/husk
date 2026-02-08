extends Node

@onready var spell: Node3D = $"../../../.."
@onready var state_chart: StateChart = $"../../.."
@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"

func _on_pulling_state_entered() -> void:
	animation_player.play("grab_object")


func _on_pulling_state_exited() -> void:
	pass # Replace with function body.


func _on_pulling_state_physics_processing(delta: float) -> void:
	if is_instance_valid(spell.grabbed_object):
		if not Input.is_action_pressed("attack_secondary"):
			state_chart.send_event("missed")
			return
			
		if spell.grabbed_object.global_position.distance_to(spell.hold_node.global_position) < 2:
			spell.grabbed_object._is_grabbed = true
			Global.player.hold_joint.node_b = spell.grabbed_object.get_path()
			spell.grabbed_object.global_transform = spell.hold_node.global_transform
			spell.grabbed_object.linear_velocity = Vector3.ZERO
			spell.grabbed_object.angular_velocity = Vector3.ZERO
			spell.grabbed_object.throw_power *= spell.throw_power_multiplier
			state_chart.send_event("hold")
		else:
			spell.grabbed_object.apply_central_impulse(-(spell.grabbed_object.global_position - Global.player.head.global_position) * (spell.grabbed_object.pull_force * delta)) #- (spell.grabbed_object.linear_velocity)* delta)
			spell.grabbed_object.apply_torque_impulse(-((spell.grabbed_object.global_position - spell.global_position) + (spell.grabbed_object.linear_velocity * delta))/30)
	else:
		state_chart.send_event("missed")
