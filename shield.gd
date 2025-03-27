extends Offhand

@onready var state_chart: StateChart = $StateChart
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func block():
	animation_player.play("blocked")
	AudioManager.play_sound(load("res://sfx/shield-guard-6963.mp3"),self.global_position,-10)
	await animation_player.animation_finished
	animation_player.play("blocked",-1,-1,true)
