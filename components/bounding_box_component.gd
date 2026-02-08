class_name bounding_box_component
extends PanelContainer

@export var mesh: MeshInstance3D
@onready var label: Label = $Label

var active: bool = false: set = _update_active

func _ready() -> void:
	self.visible = active
	label.text = mesh.name

func _update_active(value: bool):
	active = value
	visible = value

func _process(delta: float) -> void:
	if active:
		self.visible = true
		var bounding_box = get_2d_bounding_box(mesh, get_viewport().get_camera_3d())
		self.position = bounding_box.position
		self.size = bounding_box.size
	if mesh.global_position.distance_to(Global.player.global_position) < 2:
		if Global.player.camera.is_position_in_frustum(mesh.global_position):
			active = true
		else:
			active = false
	else:
		active = false

func get_2d_bounding_box(mesh_instance: MeshInstance3D, camera: Camera3D) -> Rect2:
	if not is_instance_valid(mesh_instance) or not is_instance_valid(camera):
		return Rect2()

	if not mesh:
		return Rect2()
	var aabb: AABB = mesh.get_aabb() 
	
	var global_transform: Transform3D = mesh_instance.global_transform
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF

	# Calculate and project all 8 AABB corners
	for i in range(8):
		var corner_world: Vector3 = global_transform * aabb.get_endpoint(i)
		var corner_screen: Vector2 = camera.unproject_position(corner_world)
		min_x = min(min_x, corner_screen.x)
		max_x = max(max_x, corner_screen.x)
		min_y = min(min_y, corner_screen.y)
		max_y = max(max_y, corner_screen.y)

	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)
