class_name ItemComponent
extends interact

@onready var parent: Node3D = $".."
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@export var item_pickup: item

var interactable: bool = false

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		interactable = true
		

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && interactable:
		AudioManager.play_sound(load("res://sfx/dark_souls_item.wav"),self.global_position,-4.0)
		SignalBus.item_interact.emit(item_pickup)
		Global.inventory.append(item_pickup)
		parent.queue_free()

func _process(delta: float) -> void:
	ray_cast_3d.target_position = ray_cast_3d.global_position.direction_to(Global.player.global_position)*2

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		interactable = false
		SignalBus.interact_close.emit()
