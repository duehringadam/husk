extends MarginContainer

@onready var health_component: HealthComponent = $HealthComponent
@onready var label: Label = $VBoxContainer/Label

var source

func _ready() -> void:
	EnemyManager.connect("enemy_combat_target_changed", target_changed)
	EnemyManager.connect("enemy_combat_target_take_damage", take_damage)

func target_changed(name: String, _source: Variant, target_max_hp: float, target_current_hp: float):
	if source != _source:
		source = _source
	self.show()
	label.text = name
	health_component.max_health = target_max_hp
	health_component.modify_max_health(target_max_hp)
	health_component.current_health = target_current_hp
	health_component.modify_health(target_current_hp)

func take_damage(amount: float):
	health_component.modify_health(amount)
