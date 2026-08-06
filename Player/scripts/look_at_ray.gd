extends RayCast3D

@onready var interactprompt: RichTextLabel = $"../../../UILayer/interactprompt"

var current_collider

func _process(delta: float) -> void:
	if is_colliding():
		if get_collider() is interact:
			var interact_object = get_collider()
			if interact_object.interact_type == Global.INTERACT_TYPE.PICKUP:
				interact_object.interactable = true

			if interact_object.interactable:
				interactprompt.visible = true
				match interact_object.interact_type:
					Global.INTERACT_TYPE.TALK:
						interactprompt.text = "Talk [E]"
					Global.INTERACT_TYPE.INSPECT:
						interactprompt.text = "Inspect [E]"
					Global.INTERACT_TYPE.OPEN:
						interactprompt.text = "Open [E]"
					Global.INTERACT_TYPE.CLOSE:
						interactprompt.text = "Close [E]"
					Global.INTERACT_TYPE.PICKUP:
						interactprompt.text = "Pickup [E]"
					Global.INTERACT_TYPE.ITEM:
						interactprompt.text = "Take [E]"
					_:
						interactprompt.text = ""
			else:
				interactprompt.visible = false
				return
	else:
		interactprompt.visible = false
