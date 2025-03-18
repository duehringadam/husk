extends Control

@onready var dialogue_container: PanelContainer = $DialogueContainer
@onready var dialogue: RichTextLabel = $DialogueContainer/DialogueMargin/Dialogue
@onready var animation_player: AnimationPlayer = $DialogueContainer/AnimationPlayer

func _ready() -> void:
	SignalBus.dialogue_interact.connect(show_dialogue_box)
	SignalBus.dialogue_close.connect(close_dialogue_box)


func show_dialogue_box(dialogue_text: String, duration: float, dialogue_sound: AudioStream, dialogue_position: Vector3):
	dialogue_container.show()
	animation_player.play("dialogue_Show")
	dialogue.dialogue(dialogue_text, duration, dialogue_sound, dialogue_position)

func close_dialogue_box():
	animation_player.play("dialogue_hide")
	dialogue.text = ""
	await animation_player.animation_finished
	dialogue_container.hide()
	dialogue.visible_ratio = 0.0
