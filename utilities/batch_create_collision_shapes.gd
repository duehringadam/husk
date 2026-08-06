@tool
extends EditorScript

# Target folder
const TARGET_FOLDER := "res://scenes/dungeons/Prefabs/"

func _run() -> void:
	var dir := DirAccess.open(TARGET_FOLDER)
	if not dir:
		print("Invalid folder path: ", TARGET_FOLDER)
		return
		
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var full_path = TARGET_FOLDER.path_join(file_name)
			_process_scene(full_path)
				
		file_name = dir.get_next()
		
	var interface := get_editor_interface()
	interface.get_resource_file_system().scan()
	print("--- Batch replacement complete! ---")

func _process_scene(scene_path: String) -> void:
	var packed_scene: PackedScene = load(scene_path)
	if not packed_scene:
		return
		
	var scene_root: Node = packed_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	if not scene_root:
		return
		
	var changes_made := false
	var meshes = scene_root.find_children("*", "MeshInstance3D", true, false)
	
	for mesh_node in meshes:
		if mesh_node is MeshInstance3D and mesh_node.mesh:
			
			# 1. Remove any existing StaticBody3D children first
			var removed_any := _remove_existing_static_bodies(mesh_node)
			
			# 2. Create the new StaticBody3D container
			var static_body := StaticBody3D.new()
			static_body.name = mesh_node.name + "StaticBody"
			mesh_node.add_child(static_body)
			static_body.owner = scene_root
			static_body.collision_layer = 2
			# 3. Generate the fresh physics shape
			var collision_shape := CollisionShape3D.new()
			collision_shape.name = "CollisionShape3D"
			collision_shape.shape = mesh_node.mesh.create_convex_shape()
			
			static_body.add_child(collision_shape)
			collision_shape.owner = scene_root
			
			changes_made = true
			
			if removed_any:
				print("Replaced existing collider on '", mesh_node.name, "' in scene: ", scene_path.get_file())
			else:
				print("Added new collider to '", mesh_node.name, "' in scene: ", scene_path.get_file())
			
	if changes_made:
		var new_packed := PackedScene.new()
		var error := new_packed.pack(scene_root)
		if error == OK:
			ResourceSaver.save(new_packed, scene_path)
		else:
			print("Error packing scene: ", error)
			
	scene_root.queue_free()

# Helper function to find, detach, and delete old static bodies
func _remove_existing_static_bodies(node: Node) -> bool:
	var found_any := false
	# Loop backwards to safely remove items while iterating
	var children = node.get_children()
	for i in range(children.size() - 1, -1, -1):
		var child = children[i]
		if child is StaticBody3D:
			node.remove_child(child)
			child.queue_free()
			found_any = true
	return found_any
