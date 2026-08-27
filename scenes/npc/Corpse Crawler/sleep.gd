extends Node

@export var source_npc: npc
@export var state_chart: StateChart
@export var animation_tree: AnimationTree
@export var body_bone: PhysicalBone3D
@export var physical_bone_simulator_3d: PhysicalBoneSimulator3D
@export var sleep_timer: Timer
@export var hurtbox: hurtbox_component

const VELOCITY_THRESHOLD: float = 1.0

var body_forward: Vector3 
var dot_product: float
var timer: float


func _on_sleep_state_entered() -> void:
	source_npc.fall()
	source_npc.SPEED = 0
	animation_tree.active = false


func _on_sleep_state_exited() -> void:
	timer = 0
	source_npc.global_transform.origin = body_bone.global_transform.origin

func _on_sleep_state_physics_processing(delta: float) -> void:
	if source_npc.health_component.current_health <= 0:
		state_chart.send_event("dead")
	body_forward = body_bone.global_transform.basis.z.normalized()
	dot_product = body_forward.dot(Vector3.UP)
	
	
	if body_bone.linear_velocity.length() < VELOCITY_THRESHOLD:
		timer += delta
		
	if timer >= 3.0 && sleep_timer.time_left <= 0:
		#facing up
		if dot_product >= 0.0:
			state_chart.send_event("get_up")
		#facing down
		elif dot_product < 0.0:
			state_chart.send_event("get_up")
	if timer >= 3.0 && hurtbox.just_damaged == true:
		if dot_product >= 0.0:
			state_chart.send_event("get_up")
		elif dot_product < 0.0:
			state_chart.send_event("get_up")
