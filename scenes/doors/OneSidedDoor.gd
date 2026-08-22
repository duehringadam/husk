class_name OneSidedDoor
extends StaticBody3D

@export var door: InteractableDoor

var active: bool = true

func _ready() -> void:
	door.connect("door_activated", _door_activated)

func _interact(controller: InteractionController) -> void:
	if active:
		ContextPopUp.activate()


func _door_activated(value: bool) -> void:
	active = value
	if value:
		self.queue_free()
	else:
		collision_layer = 8
