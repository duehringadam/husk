class_name DialogueInteractComponent
extends interact

@export_multiline var dialogue: Array[String]
@export var dialogue_interact_sound: AudioStream
@export var dialogue_duration: float

var interactable: bool = false

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		interactable = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && interactable:
		SignalBus.dialogue_interact.emit(dialogue, dialogue_duration, dialogue_interact_sound, self.global_position)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		interactable = false
		SignalBus.dialogue_close.emit()
