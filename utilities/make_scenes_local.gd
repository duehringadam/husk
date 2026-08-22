# Save this script as make_local.gd
@tool
extends EditorScript

# Called when the script is executed (File -> Run in Script Editor)
func _run():
	var selection = EditorInterface.get_selection().get_selected_nodes()
	var root = EditorInterface.get_edited_scene_root()
	
	if selection.is_empty():
		print("No node selected")
		return

	for node in selection:
		print("Making local: ", node.name)
		make_node_local(node, root)
		
	print("Finished making children local.")

func make_node_local(node: Node, scene_root: Node):
	# Make the node itself local if it's an instance
	node.scene_file_path = ""
	node.owner = scene_root
	
	# Recursively make all children local
	for child in node.get_children():
		make_node_local(child, scene_root)
