class_name DialogueInteractComponent
extends Area3D

@export_multiline var dialogue: String
@export var dialogue_interact_sound: AudioStream

var interactable: bool = false

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		interactable = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && interactable:
		SignalBus.dialogue_interact.emit(dialogue, 5, dialogue_interact_sound, self.global_position)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		SignalBus.dialogue_close.emit()
