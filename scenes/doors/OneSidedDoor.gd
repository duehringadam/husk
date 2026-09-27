class_name OneSidedDoor
extends StaticBody3D

@export var door: InteractableDoor

@export_multiline var context_pop_up_message: String

var active: bool = true

func _ready() -> void:
	door.connect("door_activated", _door_activated)

func _interact(controller: InteractionController) -> void:
	if active:
		ContextPopUp.set_popup_text(context_pop_up_message)
		ContextPopUp.activate()


func _door_activated(value: bool) -> void:
	active = value
	if value:
		self.queue_free()
	else:
		collision_layer = 8
