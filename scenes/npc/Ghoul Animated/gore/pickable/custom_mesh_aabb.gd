extends MeshInstance3D

var animated_aabb: AABB

func _process(_delta):
	# Assuming a MeshInstance3D with a Skeleton3D child
	var skeleton = $".."
	var mesh = self.mesh
	
	if not mesh or not skeleton:
		return

	# Start with an empty AABB
	animated_aabb = AABB() 
	
	# Get vertex data (complex; requires ArrayMesh or MeshDataTool)
	# This is a simplified conceptual approach
	var surface_array = mesh.surface_get_arrays(0)
	var vertices = surface_array[Mesh.ARRAY_VERTEX]
	
	for v in vertices:
		# Apply Skeleton transformation (highly simplified)
		var world_v = skeleton.global_transform * v
		animated_aabb = animated_aabb.expand(world_v)
		
	# Optional: Visualize
	#debug_draw_aabb(animated_aabb)
