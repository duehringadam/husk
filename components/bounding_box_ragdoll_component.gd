class_name bounding_box_ragdoll_component
extends PanelContainer

@onready var label: Label = $Label
@export var label_name: String
@export var physical_bone: PhysicalBone3D
@export var on_screen_identifier: VisibleOnScreenNotifier3D


var active: bool = false: set = _update_active

func _ready() -> void:
	self.visible = active
	label.text = label_name

func _update_active(value: bool):
	active = value
	visible = value

func _process(delta: float) -> void:
	if active:
		self.visible = true
		var bounding_box = get_2d_bounding_box(on_screen_identifier, get_viewport().get_camera_3d())
		self.position = bounding_box.position
		self.size = bounding_box.size
	if physical_bone:
		if physical_bone.global_position.distance_to(Global.player.global_position) < 2:
			if Global.player.camera.is_position_in_frustum(physical_bone.global_position):
				active = true
			else:
				active = false
		else:
			active = false

func get_2d_bounding_box(on_screen_identifier: VisibleOnScreenNotifier3D, camera: Camera3D) -> Rect2:
	if not is_instance_valid(on_screen_identifier) or not is_instance_valid(camera):
		return Rect2()

	if not on_screen_identifier:
		return Rect2()
	var aabb: AABB = on_screen_identifier.get_aabb() 
	
	var global_transform = physical_bone.global_transform
	
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
