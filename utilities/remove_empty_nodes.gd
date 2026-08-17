@tool
extends EditorScript

# Main entry point for the editor script
func _run():
	var root_node = EditorInterface.get_edited_scene_root()
	if not root_node:
		printerr("No active scene found in the editor.")
		return
		
	var removed_count = cleanup_empty_node3ds(root_node)
	print("Cleanup complete. Removed ", removed_count, " empty Node3D(s).")

# Recursively traverses and deletes empty Node3D nodes
func cleanup_empty_node3ds(node: Node) -> int:
	var count = 0
	
	# Process children first (bottom-up approach)
	# Iterate backwards to safely delete items while looping
	var children = node.get_children()
	for i in range(children.size() - 1, -1, -1):
		count += cleanup_empty_node3ds(children[i])
		
	# Check if current node is Node3D, has no children, and isn't the scene root
	if node is Node3D and node.get_child_count() == 0 and node != EditorInterface.get_edited_scene_root():
		if node is not MeshInstance3D && node is not StaticBody3D && node is not CollisionShape3D:
			print("Removing empty Node3D: ", node.name)
			node.free() # Editor scripts use free() safely since the game is not running
			return count + 1
		
	return count
