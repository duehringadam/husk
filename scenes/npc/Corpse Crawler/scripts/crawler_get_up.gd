extends Node

@export var source_npc: CharacterBody3D
@export var animation_tree: AnimationTree
@export var state_chart: StateChart

@export var bone_sim: PhysicalBoneSimulator3D
@export var hip_bone: PhysicalBone3D

func _ready() -> void:
	animation_tree["parameters/playback"].state_finished.connect(on_state_finished)

func _on_get_up_state_entered() -> void:
	source_npc.collision_layer = 4
	animation_tree.active = true
	
	var hip_forward = hip_bone.global_transform.basis.z.normalized()
	var dot_product = hip_forward.dot(Vector3.UP)
	
	var hip_transform: Transform3D = hip_bone.transform
	var look_dir: Vector3 = hip_transform.basis.z
	
	if dot_product > 0.0:
		look_dir = -look_dir
	
	var target_angle: float = atan2(look_dir.x, look_dir.z)
	
	source_npc.global_transform.basis = Basis.from_euler(Vector3(0, target_angle, 0))
	
	#animation_tree["parameters/playback"].travel("get_up")
	var tween = get_tree().create_tween()
	tween.tween_property(bone_sim, "influence", 0.0, .5)
	tween.tween_callback(func(): bone_sim.physical_bones_stop_simulation(); state_chart.send_event("idle"))


func _on_get_up_state_exited() -> void:
	bone_sim.influence = 1.0


func _on_get_up_state_physics_processing(delta: float) -> void:
	pass # Replace with function body.
	
func on_state_finished(state: StringName):
	if state == "get_up":
		state_chart.send_event("idle")
