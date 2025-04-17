extends Offhand

@onready var state_chart: StateChart = $StateChart
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var primary_active_bool: bool = false

func _ready() -> void:
	SignalBus.connect("primary_active", primary_active)
	
func primary_active(value: bool):
	primary_active_bool = value

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_secondary") && !primary_active_bool:
		state_chart.send_event("secondary_attack")

func block():
	animation_player.play("blocked")
	AudioManager.play_sound(load("res://sfx/shield-guard-6963.mp3"),self.global_position,-10)
	await animation_player.animation_finished
	animation_player.play("blocked",-1,-1,true)
