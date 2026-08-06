@tool
extends EditorScript

# Configuration for LOD generation
const NORMAL_MERGE_ANGLE = 25.0
const NORMAL_SPLIT_ANGLE = 60.0

# Extreme LOD configuration (Lower forces faster transitions)
# Godot default is 1.0. Lower values (e.g., 0.1) force low-res meshes to appear sooner.
const EXTREME_LOD_BIAS = 0.003

func _run():
	# Get the currently selected node in the scene tree
	var editor_interface = get_editor_interface()
	var selection = editor_interface.get_selection()
	var selected_nodes = selection.get_selected_nodes()
	
	if selected_nodes.is_empty():
		push_warning("No node selected. Please select a parent node in the Scene tree.")
		return
		
	var parent_node = selected_nodes[0]
	var children = parent_node.get_children()
	
	if children.is_empty():
		print("Selected node '%s' has no children to process." % parent_node.name)
		return
		
	print("Processing children of: ", parent_node.name)
	
	var total_modified = 0
	
	# Loop through each immediate child of the selected node
	for child in children:
		total_modified += _process_node_tree(child)
		
	if total_modified > 0:
		print("Successfully updated %d MeshInstance3D(s) within the children of '%s'." % [total_modified, parent_node.name])
	else:
		print("No MeshInstance3D nodes found within the children.")

func _process_node_tree(root_node: Node) -> int:
	var mesh_instances = _find_mesh_instances(root_node)
	var modified_count = 0
	
	for mi in mesh_instances:
		# Set the extreme LOD bias on the instance node
		mi.lod_bias = EXTREME_LOD_BIAS
		modified_count += 1
		
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
				
	return modified_count

func _find_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var results: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		results.append(node)
	for child in node.get_children():
		results.append_array(_find_mesh_instances(child))
	return results
