@tool
extends EditorScript

const TARGET_FOLDER = "res://scenes/Hivemind/CastleOfEternalMists/Prefabs/"
const TEXEL_SIZE = 0.05

func _run():
	var dir = DirAccess.open(TARGET_FOLDER)
	if not dir:
		print("Error: Could not open folder at ", TARGET_FOLDER)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		# Only process .tscn scene files
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var full_path = TARGET_FOLDER + file_name
			process_scene_file(full_path)
		
		file_name = dir.get_next()
	
	print("--- Batch Processing Complete ---")

func process_scene_file(path: String):
	var scene_resource = load(path)
	if not scene_resource is PackedScene: return
	
	var root_node = scene_resource.instantiate()
	var meshes_processed = 0
	
	# Recursive search for meshes
	meshes_processed = find_and_unwrap(root_node, root_node)
	
	if meshes_processed > 0:
		var packed_scene = PackedScene.new()
		var error = packed_scene.pack(root_node)
		
		if error == OK:
			ResourceSaver.save(packed_scene, path)
			print("Updated [", meshes_processed, " meshes] in: ", path)
		else:
			print("Failed to save: ", path)
	
	root_node.free()

func find_and_unwrap(node: Node, scene_root: Node) -> int:
	var count = 0
	if node is MeshInstance3D:
		unwrap_mesh(node)
		count += 1
	
	for child in node.get_children():
		count += find_and_unwrap(child, scene_root)
	return count

func unwrap_mesh(node: MeshInstance3D):
	var old_mesh = node.mesh
	if not old_mesh: return
	
	# 1. Preserve materials by duplicating and re-assigning slots
	var new_mesh = old_mesh.duplicate()
	for i in range(old_mesh.get_surface_count()):
		new_mesh.surface_set_material(i, old_mesh.surface_get_material(i))
	
	# 2. Perform UV2 Unwrap
	var err = new_mesh.lightmap_unwrap(node.global_transform, TEXEL_SIZE)
	
	if err == OK:
		node.mesh = new_mesh
		# Ensures UV2 data is saved inside the .tscn file
		new_mesh.resource_local_to_scene = true 
