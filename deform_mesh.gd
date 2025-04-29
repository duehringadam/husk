extends MeshInstance3D

@export var target_deform_mesh_instance: MeshInstance3D
@export var target_deformer: DM_Deformer
@export var health_component: HealthComponent
@export var collision_shape: CollisionShape3D

func _ready() -> void:
	if !health_component.is_connected("health_changed", _update_mesh):
		health_component.connect("health_changed", _update_mesh)
	mesh = target_deform_mesh_instance.mesh
	
func _update_mesh(amount, current_health):
	if amount < 0:
		target_deformer.radius = clampf(target_deformer.radius+.025,0.1,0.2)
		mesh = target_deform_mesh_instance.mesh
		var collide = mesh.create_convex_shape()
		collision_shape.shape = collide
		

func _on_gate_2_body_entered(body: Node) -> void:
	AudioManager.play_sound(load("res://sfx/metal-knock-2-103060.mp3"),body.global_position,-4)


func _on_gate_body_entered(body: Node) -> void:
	pass # Replace with function body.
