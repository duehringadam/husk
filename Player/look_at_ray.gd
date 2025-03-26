extends RayCast3D

@onready var interactprompt: RichTextLabel = $"../../../UILayer/interactprompt"
@onready var interactframe: NinePatchRect = $"../../../UILayer/interactframe"

func _process(delta: float) -> void:
	if is_colliding() and get_collider() is interact:
		var interact_object = get_collider() as interact
		if interact_object.interactable:
			interactprompt.visible = true
			match interact_object.interact_type:
				Global.INTERACT_TYPE.TALK:
					interactprompt.text = "Talk [F]"
				Global.INTERACT_TYPE.INSPECT:
					interactprompt.text = "Inspect [F]"
				Global.INTERACT_TYPE.OPEN:
					interactprompt.text = "Open [F]"
				Global.INTERACT_TYPE.CLOSE:
					interactprompt.text = "Close [F]"
				Global.INTERACT_TYPE.PICKUP:
					interactprompt.text = "Pickup [F]"
				_:
					interactprompt.text = ""
			
			if interact_object.visual_root:
				var aabb: AABB
				var search: Array[Node] = [ interact_object.visual_root ]
				for node in search:
					search.append_array(node.get_children(true))
					if node is VisualInstance3D:
						var node_aabb = node.global_transform * node.get_aabb()
						if aabb:
							aabb = aabb.merge(node_aabb)
						else:
							aabb = node_aabb
				
				var camera = get_viewport().get_camera_3d()
				var min_x := INF
				var min_y := INF
				var max_x := -INF
				var max_y := -INF
				for i in range(8):
					if not camera.is_position_behind(aabb.get_endpoint(i)):
						## screen-space coordinates of aabb corner
						var pos := get_viewport().get_camera_3d().unproject_position(aabb.get_endpoint(i))
						min_x = minf(min_x, pos.x)
						min_y = minf(min_y, pos.y)
						max_x = maxf(max_x, pos.x)
						max_y = maxf(max_y, pos.y)
				
				interactframe.position = Vector2(min_x, min_y)
				interactframe.size = Vector2(max_x - min_x, max_y - min_y)
				interactframe.visible = true
			else:
				interactframe.visible = false
		else:
			interactprompt.visible = false
			interactframe.visible = false
