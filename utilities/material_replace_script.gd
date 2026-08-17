@tool
extends EditorScript

# SET THE FOLDER PATH TO SCAN
const TARGET_DIR = "res://scenes/Hivemind/CastleOfEternalMists/URP/Art/Materials/Instances/"

func _run():
	if not DirAccess.dir_exists_absolute(TARGET_DIR):
		printerr("Directory not found: ", TARGET_DIR)
		return
		
	process_directory(TARGET_DIR)
	# Refresh the editor's view of the filesystem
	EditorInterface.get_resource_filesystem().scan()
	print("Filesystem update complete.")

func process_directory(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir():
				# Recursively scan subfolders
				process_directory(path + file_name + "/")
			elif file_name.ends_with(".tres") or file_name.ends_with(".material"):
				update_material_file(path + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

func update_material_file(file_path: String):
	var old_res = ResourceLoader.load(file_path)
	
	if old_res is Material:
		# 1. Create the new StandardMaterial3D
		var new_mat = StandardMaterial3D.new()
		
		# 2. Extract textures from the old resource
		# This works if the old material was also a BaseMaterial3D
		new_mat.albedo_texture = old_res.get_shader_parameter("BaseMap")
		new_mat.normal_enabled = true
		new_mat.normal_texture = old_res.get_shader_parameter("NormalMap")
		# Add other maps here (roughness, metallic, etc.) as needed
		
		# 3. Overwrite the original file with the new material type
		var error = ResourceSaver.save(new_mat, file_path)
		if error == OK:
			print("Updated: ", file_path)
		else:
			printerr("Failed to save: ", file_path, " Error code: ", error)
