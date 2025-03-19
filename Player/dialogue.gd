extends RichTextLabel

var new_dialogue: bool = false
var dialogue_visible_char = 0
var dialogue_sound: AudioStream
var dialogue_position: Vector3
var dialogue_text
var idx: int = 0
var duration: float
var tween: Tween = null

@onready var dialoguetimer: Timer = $"../dialoguetimer"
@onready var user_interface: Control = $"../../.."


func dialogue(_dialogue_text: Array, _duration: float, _dialogue_sound: AudioStream, _dialogue_position: Vector3):
	idx = 0
	dialogue_text = _dialogue_text
	dialogue_position = _dialogue_position
	dialogue_sound = _dialogue_sound
	duration = _duration
	dialogue_display()
	print(_dialogue_text)

func _process(delta: float) -> void:
	if new_dialogue:
		if dialogue_visible_char != visible_characters:
			dialogue_visible_char = visible_characters
			if visible_characters % 2 != 0:
				AudioManager.play_sound(dialogue_sound,dialogue_position,2.0)


func _on_dialoguetimer_timeout() -> void:
	if idx+1 > dialogue_text.size()-1:
		user_interface.close_dialogue_box()
	else:
		idx = clampi(idx+1,0,dialogue_text.size()-1)
		dialogue_display()

func dialogue_display():
	visible_ratio = 0
	text = dialogue_text[idx]
	tween = get_tree().create_tween()
	tween.tween_property(self,"visible_ratio",1.0,duration)
	new_dialogue = true
	await tween.finished
	dialoguetimer.start()
		
