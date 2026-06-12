extends NinePatchRect


@onready var level_value: Label = %levelValue
@onready var ichor_value: Label = %ichorValue
@onready var health_value: Label = %healthValue
@onready var stamina_value: Label = %staminaValue
@onready var vigor_value: Label = %vigorValue
@onready var strength_value: Label = %strengthValue
@onready var dex_value: Label = %dexValue
@onready var endurance_value: Label = %enduranceValue
@onready var int_value: Label = %intValue
@onready var faith_value: Label = %faithValue
@onready var strike_resistance: Label = %strikeResistance
@onready var slash_resistance: Label = %slashResistance
@onready var thrust_resistance: Label = %thrustResistance
@onready var magic_resistance: Label = %magicResistance
@onready var holy_resistance: Label = %holyResistasnce
@onready var murk_resistance: Label = %murkResistance
@onready var fire_resistance: Label = %fireResistance
@onready var poison_resistance: Label = %poisonResistance

var current_hp: float
var max_hp: float

var current_stam: float
var max_stam: float

func _ready() -> void:
	SignalBus.connect("player_stats_changed", _update_player_stats)
	SignalBus.connect("player_resists_changed", _update_player_resists)
	SignalBus.connect("player_current_health_changed", _update_player_current_hp)
	SignalBus.connect("player_max_health_changed", _update_player_max_hp)
	SignalBus.connect("player_max_stamina_changed", _update_player_max_stamina)
	SignalBus.connect("player_current_stamina_changed", _update_player_current_stamina)

func _update_player_stats(stats: Dictionary[ItemEquippableType.ITEM_REQUIRED_STAT, int]):
	for i in stats.keys():
		match ItemEquippableType.ITEM_REQUIRED_STAT.keys()[i]:
			"VIGOR":
				vigor_value.text = str(stats[i])
			"ENDURANCE":
				endurance_value.text = str(stats[i])
			"STRENGTH":
				strength_value.text = str(stats[i])
			"DEXTERITY":
				dex_value.text = str(stats[i])
			"INTELLIGENCE":
				int_value.text = str(stats[i])
			"FAITH":
				faith_value.text = str(stats[i])
	

func _update_player_resists(resists: Dictionary[DamageTypes.DAMAGE_TYPES, float]):
	for i in resists.keys():
		match DamageTypes.DAMAGE_TYPES.keys()[i]:
			"STRIKE":
				strike_resistance.text = str(int(resists[i] * 100))
			"SLASH":
				slash_resistance.text = str(int(resists[i] * 100))
			"THRUST":
				thrust_resistance.text = str(int(resists[i] * 100))
			"MAGIC":
				magic_resistance.text = str(int(resists[i] * 100))
			"HOLY":
				holy_resistance.text = str(int(resists[i] * 100))
			"MURK":
				murk_resistance.text = str(int(resists[i] * 100))
			"FIRE":
				fire_resistance.text = str(int(resists[i] * 100))
			"POISON":
				poison_resistance.text = str(int(resists[i] * 100))

func _update_player_current_hp(value: float):
	current_hp = value
	_update_health_text()

func _update_player_max_hp(value: float):
	max_hp = value
	_update_health_text()

func _update_health_text():
	health_value.text = str(int(current_hp)) + "/" + str(int(max_hp))


func _update_player_max_stamina(value: float):
	max_stam = value
	_update_stamina_text()

func _update_player_current_stamina(value: float):
	current_stam = value
	_update_stamina_text()

func _update_stamina_text():
	stamina_value.text = str(int(current_stam)) + "/" + str(int(max_stam))
