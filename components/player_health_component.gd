extends HealthComponent


func _ready() -> void:
	current_health = max_health
	emit_signal("max_health_changed", 0, max_health)
	emit_signal("health_changed", 0, current_health)
	SignalBus.emit_signal("player_current_health_changed", current_health)
	SignalBus.emit_signal("player_max_health_changed", max_health)

func modify_health(amount: float):
	current_health = clampf(current_health + amount, 0, max_health)
	emit_signal("health_changed", amount, current_health)
	SignalBus.emit_signal("player_current_health_changed", current_health)
	if current_health <= 0:
		emit_signal("died")
	
func modify_max_health(amount: float):
	max_health += amount
	modify_health(max_health)
	emit_signal("max_health_changed", amount, max_health)
	SignalBus.emit_signal("player_max_health_changed", max_health)

func set_max_health(amount:float):
	max_health = amount
	emit_signal("max_health_changed", amount, max_health)
	SignalBus.emit_signal("player_max_health_changed", max_health)

func set_current_health(amount:float):
	current_health = clampf(amount, 0, max_health)
	emit_signal("health_changed", amount, current_health)
	SignalBus.emit_signal("player_current_health_changed", current_health)
