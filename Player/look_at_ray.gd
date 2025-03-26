extends RayCast3D

@onready var interactprompt: RichTextLabel = $"../../../UILayer/interactprompt"

func _process(delta: float) -> void:
	if is_colliding():
		if get_collider() is interact:
			var interact_object = get_collider()
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
			else:
				interactprompt.visible = false
				return
	else:
		interactprompt.visible = false
				
