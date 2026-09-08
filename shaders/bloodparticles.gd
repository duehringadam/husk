extends Node3D

@export var detection_radius: float = 5.0
@export_flags_3d_physics var collision_mask: int = 1

@onready var blood_pos: RayCast3D = $blood_pos
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var blood_decal = preload("res://scenes/VFX/Scenes/Blood_Pool_Decal.tscn")
var space_state

func _ready() -> void:
	get_tree().create_timer(1).timeout.connect(func(): self.queue_free())

func _physics_process(delta: float) -> void:
	space_state = get_world_3d().direct_space_state

func take_damage() -> void:
	animation_player.play("Init")
	
	var surface_data = await get_closest_surface_data()
	
	if surface_data.is_empty():
		return # No surface found to splatter on

	var hit_point = surface_data["point"]
	var hit_normal = surface_data["normal"]

	var decal = blood_decal.instantiate() as Decal
	get_tree().current_scene.add_child(decal)

	decal.global_position = hit_point

	decal.global_transform.basis = Basis.looking_at(hit_normal, Vector3.UP)
	
	decal.rotate_object_local(Vector3.RIGHT, deg_to_rad(-90))


func _on_hurtbox_component_damage_taken(actual: float, source: DamageComponent, hit_dir: Vector3) -> void:
	take_damage() 

func get_closest_surface_data() -> Dictionary:
	await get_tree().physics_frame
	
	if not space_state: return {}

	var sphere = SphereShape3D.new()
	sphere.radius = detection_radius

	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform = global_transform
	query.collision_mask = collision_mask

	var results = space_state.intersect_shape(query)
	if results.is_empty(): return {}

	# Query deep contact data
	var rest_info = space_state.get_rest_info(query)
	if not rest_info.is_empty():
		var contact_point = rest_info.get("point", Vector3.INF)
		# Extract the normal vector pointing directly away from the surface!
		var contact_normal = rest_info.get("normal", Vector3.UP) 
		
		return {"point": contact_point, "normal": contact_normal}

	return {}
