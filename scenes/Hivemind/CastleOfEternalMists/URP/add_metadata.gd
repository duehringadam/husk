@tool
extends EditorScript

const META_KEY = "ground_type"
const META_VALUE = "stone"

func _run() -> void:
	# 1. Get the currently selected nodes in the Scene dock
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	
	if selection.is_empty():
		printerr("Please select a parent node in the Scene dock first!")
		return

	var count = 0
	
	# 2. Iterate through each selected node (in case you selected multiple parents)
	for parent in selection:
		# 3. Find all children of the selected node that are StaticBody3D
		# The 'true' argument ensures it searches recursively (all descendants)
		var static_bodies = parent.find_children("*", "StaticBody3D", true)
		
		# Also check if the selected node itself is a StaticBody3D
		if parent is StaticBody3D:
			static_bodies.append(parent)
			
		for node in static_bodies:
			node.set_meta(META_KEY, META_VALUE)
			count += 1
			print("Added meta to descendant: ", node.name)

	if count > 0:
		print("Finished! Added metadata to ", count, " StaticBody3D nodes under selection.")
	else:
		print("No StaticBody3D nodes found under the selected parent(s).")
