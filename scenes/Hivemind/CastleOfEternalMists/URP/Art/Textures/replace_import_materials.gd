@tool
extends EditorScenePostImport

# The folder path where your external .tres materials live
const MATERIAL_FOLDER_PATH = "res://scenes/Hivemind/CastleOfEternalMists/URP/Art/Materials/Instances/"

func _post_import(scene: Node) -> Object:
	_iterate_and_replace(scene)
	return scene

func _iterate_and_replace(node: Node):
	if node is MeshInstance3D:
		var mesh: Mesh = node.mesh
		if mesh:
			# Loop through all material slots on the mesh
			for i in range(mesh.get_surface_count()):
				var original_material = mesh.surface_get_material(i)
				if original_material:
					var mat_name = original_material.resource_name
					
					if not mat_name.is_empty():
						# Construct the path: res://materials/MaterialName.tres
						var expected_path = MATERIAL_FOLDER_PATH.path_join(mat_name + ".tres")
						
						# Check if the file exists before attempting to load it
						if FileAccess.file_exists(expected_path):
							var external_material = load(expected_path) as Material
							if external_material:
								node.set_surface_override_material(i, external_material)
						else:
							printerr("Material Replacer: File not found at ", expected_path)

	# Recursively iterate through all children in the scene
	for child in node.get_children():
		_iterate_and_replace(child)
