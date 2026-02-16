extends ProgressBar
@onready var damage_bar: ProgressBar = $damageBar
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

###################
# a signal is emitted any time this value is changed to execute _set_health() func
###################
#var health = 0 : set = _set_health

func _on_health_changed(amount: float, new_value: float) -> void:
	value = new_value
	if amount < 0:
		timer.start()
	if amount < -(max_value/2):
		animation_player.play("shake")

func _on_max_health_changed(amount: float, new_value: float) -> void:
	max_value = new_value
	damage_bar.max_value = new_value
	
###################
# tween the values of the health bars
###################
func _on_timer_timeout() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(damage_bar,"value",value,.12).set_ease(Tween.EASE_OUT)
	

func _process(delta: float) -> void:
	if damage_bar.value < value:
		damage_bar.value = value
