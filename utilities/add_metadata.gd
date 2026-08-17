@tool
extends EditorScript

# Use: File -> Run in the Script Editor.
# This script recursively scans your project for scenes, 
# opens them, finds StaticBody3D nodes, and injects metadata.

const TARGET_META_KEY = "ground_type"
const TARGET_META_VAL = "stone"

func _run():
	print("--- Starting StaticBody3D Metadata Scan ---")
	_process_directory("res://scenes/dungeons/Prefabs/")
	print("--- Scan Complete ---")

# Recursively traverses the project file system
func _process_directory(path: String):
	var dir = DirAccess.open(path)
	if not dir:
		printerr("Failed to open directory: ", path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		var full_path = path.path_join(file_name)
		
		if dir.current_is_dir():
			# Recursive step for subfolders
			_process_directory(full_path)
		elif file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
			# Process found scene files
			_check_and_update_scene(full_path)

		file_name = dir.get_next()

# Loads scenes and injects metadata if needed
func _check_and_update_scene(scene_path: String):
	var scene_resource = load(scene_path)
	if not scene_resource is PackedScene:
		return

	var root_node = scene_resource.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	if not root_node:
		return

	var modification_made = false
	
	# Check root node
	if root_node is StaticBody3D:
		if _apply_metadata(root_node):
			modification_made = true

	# Check all descendants
	for child in root_node.find_children("*", "StaticBody3D", true, false):
		if _apply_metadata(child):
			modification_made = true

	# Save scene back to disk only if changes occurred
	if modification_made:
		var packed_scene = PackedScene.new()
		var status = packed_scene.pack(root_node)
		if status == OK:
			ResourceSaver.save(packed_scene, scene_path)
			print("Updated metadata in scene: ", scene_path)
		else:
			printerr("Failed to pack scene: ", scene_path)
			
	root_node.queue_free()

# Safely applies metadata and returns true if a change happened
func _apply_metadata(node: Node) -> bool:
	if not node.has_meta(TARGET_META_KEY) or node.get_meta(TARGET_META_KEY) != TARGET_META_VAL:
		node.set_meta(TARGET_META_KEY, TARGET_META_VAL)
		return true
	return false
