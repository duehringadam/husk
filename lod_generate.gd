@tool
extends EditorScript

# Configuration for LOD generation
const TARGET_DIR = "res://scenes/Hivemind/CastleOfEternalMists/Prefabs/"
const NORMAL_MERGE_ANGLE = 25.0
const NORMAL_SPLIT_ANGLE = 60.0

# Extreme LOD configuration (Lower forces faster transitions)
# Godot default is 1.0. Lower values (e.g., 0.1) force low-res meshes to appear sooner.
const EXTREME_LOD_BIAS = 0.05

func _run():
	var dir = DirAccess.open(TARGET_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				_process_scene(TARGET_DIR + file_name)
			file_name = dir.get_next()
		print("LOD and Bias processing complete.")
	else:
		push_error("Could not open directory: " + TARGET_DIR)

func _process_scene(path: String):
	var scene = load(path) as PackedScene
	if not scene: return
	
	var root = scene.instantiate()
	var mesh_instances = _find_mesh_instances(root)
	var modified = false
	
	for mi in mesh_instances:
		# Set the extreme LOD bias on the instance node
		mi.lod_bias = EXTREME_LOD_BIAS
		modified = true
		
		# Skip mesh data optimization if there is no mesh attached
		var original_mesh = mi.mesh
		if not original_mesh: continue
		
		# Convert standard Mesh to ImporterMesh
		var importer_mesh = ImporterMesh.from_mesh(original_mesh)
		if not importer_mesh: continue
		
		# Generate extreme built-in LOD data
		importer_mesh.generate_lods(NORMAL_MERGE_ANGLE, NORMAL_SPLIT_ANGLE, [])
		
		# Convert back to standard ArrayMesh and re-assign
		mi.mesh = importer_mesh.get_mesh()
		
		# Restore or override surface materials if they were dropped
		for i in range(original_mesh.get_surface_count()):
			var mat = mi.get_surface_override_material(i)
			if mat:
				mi.set_surface_override_material(i, mat)

	if modified:
		# Save the updated node setup back to the file system
		var packed_scene = PackedScene.new()
		var error = packed_scene.pack(root)
		if error == OK:
			ResourceSaver.save(packed_scene, path)
			print("Updated LODs and Bias for: ", path)
		else:
			push_error("Failed to pack scene: " + path)
		
	root.queue_free()

func _find_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var results: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		results.append(node)
	for child in node.get_children():
		results.append_array(_find_mesh_instances(child))
	return results
