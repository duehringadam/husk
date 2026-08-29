extends MarginContainer

@export var health: HealthComponent


func _ready() -> void:
	if !health.max_health_changed.is_connected(_update_size):
		health.max_health_changed.connect(_update_size)
	custom_maximum_size.x = get_window().size.x/2


func _update_size(amount: float, new_value: float):
	size.x = (custom_minimum_size.x * (new_value/health.base_health))/2
