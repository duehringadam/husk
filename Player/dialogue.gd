extends RichTextLabel

var new_dialogue: bool = false
var dialogue_visible_char = 0
var dialogue_sound: AudioStream
var dialogue_position: Vector3

func dialogue(dialogue_text: String, duration: float, _dialogue_sound: AudioStream, _dialogue_position: Vector3):
	text = dialogue_text
	new_dialogue = true
	dialogue_position = _dialogue_position
	dialogue_sound = _dialogue_sound
	var tween = get_tree().create_tween()
	tween.tween_property(self,"visible_ratio",1.0,duration)


func _process(delta: float) -> void:
	if new_dialogue:
		if dialogue_visible_char != visible_characters:
			dialogue_visible_char = visible_characters
			if visible_characters % 2 != 0:
				AudioManager.play_sound(dialogue_sound,dialogue_position,4.0)
