@tool
extends EditorScript

# Run this script using File -> Run in the script editor
func _run():
	var scene_root = get_editor_interface().get_edited_scene_root()
	for node in scene_root.find_children("*", "Node3D"): # Use StaticBody3D if in 3D
		if not _has_shape(node):
			print("StaticBody without shape: ", node.name)
			node.queue_free()
	print("Filtering complete.")

func _has_shape(body: Node) -> bool:
	if body.get_child_count() == 0:
		return false
	else:
		return true
