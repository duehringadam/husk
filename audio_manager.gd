extends Node

###################
# Takes in an audio, puts it on a specific audio stream and randomizes its pitch
# it adds an audiostreamplayer, plays audio, deletes audiostreamplayer onces audio is done.
###################
func play_sound(stream: AudioStream, position, audio_in_decibels):
	var instance = AudioStreamPlayer3D.new()
	instance.volume_db = audio_in_decibels
	instance.pitch_scale = randf_range(0.9,1.2)
	instance.bus = "SFX"
	instance.stream = stream
	instance.finished.connect(remove_node.bind(instance))
	add_child(instance)
	instance.global_position = position
	instance.play()
	
	
func play_sound_normal(stream: AudioStream, position, audio_in_decibels):
	var instance = AudioStreamPlayer3D.new()
	instance.volume_db = audio_in_decibels
	instance.pitch_scale = 1
	instance.bus = "SFX"
	instance.stream = stream
	instance.finished.connect(remove_node.bind(instance))
	add_child(instance)
	instance.global_position = position
	instance.play()

func play_sound_non_positional(stream: AudioStream, audio_in_decibels):
	var instance = AudioStreamPlayer3D.new()
	instance.volume_db = audio_in_decibels
	instance.pitch_scale = randf_range(0.9,1.2)
	instance.bus = "SFX"
	instance.stream = stream
	instance.finished.connect(remove_node.bind(instance))
	add_child(instance)
	instance.play()

func remove_node(instance: AudioStreamPlayer3D):
	instance.queue_free()
