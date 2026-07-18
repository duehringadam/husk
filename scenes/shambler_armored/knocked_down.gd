extends Node

@export var source_npc: npc
@export var state_chart: StateChart
@export var animation_tree: AnimationTree
@export var hip_bone: PhysicalBone3D
@export var physical_bone_simulator_3d: PhysicalBoneSimulator3D

const VELOCITY_THRESHOLD: float = 1.0

var hip_forward: Vector3 
var dot_product: float
var timer: float
var animation_state_tree_root
var on_ground_node
var get_up_node

func _on_knocked_down_state_entered() -> void:
	source_npc.collision_layer = 0
	physical_bone_simulator_3d.influence = 1.0
	animation_tree.active = false
	source_npc.fall()
	timer = 0.0
	animation_state_tree_root = animation_tree.get("tree_root")
	on_ground_node = animation_state_tree_root.get_node("on_ground")
	get_up_node = animation_state_tree_root.get_node("get_up")

func _on_knocked_down_state_exited() -> void:
	timer = 0.0
	source_npc.global_transform.origin = hip_bone.global_transform.origin

func _on_knocked_down_state_physics_processing(delta: float) -> void:
	hip_forward = hip_bone.global_transform.basis.z.normalized()
	dot_product = hip_forward.dot(Vector3.UP)
	
	
	if hip_bone.linear_velocity.length() < VELOCITY_THRESHOLD:
		timer += delta
	
	if timer >= 3.0:
		#facing up
		if dot_product >= 0.0:
			on_ground_node.animation = "Hit_B_1_InPlace/on_ground"
			get_up_node.animation = "Hit_B_1_InPlace/get_up_back"
			state_chart.send_event("get_up")
		#facing down
		elif dot_product < 0.0:
			on_ground_node.animation = "Hit_F_4_InPlace/on_ground_stomach"
			get_up_node.animation = "Hit_F_4_InPlace/get_up_stomach"
			state_chart.send_event("get_up")
