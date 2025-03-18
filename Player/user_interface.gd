extends Control

var can_open: bool = true

@onready var dialogue_container: PanelContainer = $DialogueContainer
@onready var dialogue: RichTextLabel = $DialogueContainer/DialogueMargin/Dialogue
@onready var animation_player: AnimationPlayer = $DialogueContainer/AnimationPlayer

func _ready() -> void:
	SignalBus.dialogue_interact.connect(show_dialogue_box)
	SignalBus.dialogue_close.connect(close_dialogue_box)


func show_dialogue_box(dialogue_text: Array, duration: float, dialogue_sound: AudioStream, dialogue_position: Vector3):
	if !can_open:
		return
		
	dialogue_container.show()
	animation_player.play("dialogue_Show")
	dialogue.dialogue(dialogue_text, duration, dialogue_sound, dialogue_position)
	can_open = false

func close_dialogue_box():
	can_open = true
	animation_player.play("dialogue_hide")
	dialogue.text = ""
	await animation_player.animation_finished
	dialogue_container.hide()
	dialogue.visible_ratio = 0.0
