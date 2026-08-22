extends MarginContainer

var added_currency_value: int
var player_currency: int
var tween: Tween

@onready var currency_label: Label = %currencyLabel
@onready var added_currency: Label = %addedCurrency
@onready var currency_timer: Timer = $currencyTimer
@onready var currency_gain: AudioStreamPlayer = $currencyGain

func _ready() -> void:
	if !SignalBus.is_connected("enemy_currency_dropped", _update_currency):
		SignalBus.connect("enemy_currency_dropped", _update_currency)
	if SaveManager.get_player_currency_from_config("currency",0) != null:
		player_currency = SaveManager.get_player_currency_from_config("currency",0)
		currency_label.text = str(player_currency)


func _update_currency(value: int):
	if value > 0:
		if tween:
			tween.kill()
		added_currency_value += value
		added_currency.text = "+" + str(roundi(added_currency_value))
		currency_timer.start()
		SaveManager.set_player_currency("currency", player_currency + added_currency_value)
	if value < 0:
		if player_currency >= abs(value):
			added_currency_value += value
			added_currency.text = str(roundi(added_currency_value))
			currency_timer.start()
			SaveManager.set_player_currency("currency", player_currency + added_currency_value)

func _on_currency_timer_timeout() -> void:
	currency_gain.play()
	added_currency.text = ""
	tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.set_parallel()
	tween.tween_method(
		func(current_value: int): 
		currency_label.text = str(roundi(current_value)), 
		player_currency, 
		player_currency+added_currency_value,
		2.0)
	tween.tween_method(
		func(current_value: int): 
		added_currency.text = "+" + str(roundi(current_value)), 
		added_currency_value, 
		0,
		2.0)
	await tween.finished
	player_currency += added_currency_value
	added_currency.text = ""
	added_currency_value = 0
	
