extends MarginContainer

@onready var health_component: HealthComponent = $HealthComponent
@onready var label: Label = $VBoxContainer/Label
@onready var player_health: ProgressBar = $VBoxContainer/playerHealth

var source

func _ready() -> void:
	EnemyManager.connect("enemy_combat_target_changed", target_changed)
	EnemyManager.connect("enemy_combat_target_take_damage", take_damage)

func target_changed(name: String, _source: Variant, target_max_hp: float, target_current_hp: float):
	if source != _source:
		source = _source
		health_component.set_max_health(target_max_hp)
		health_component.set_current_health(target_current_hp)
		self.show()
		label.text = name


func take_damage(amount: float, _source: Variant):
	if source == _source:
		health_component.modify_health(amount)
