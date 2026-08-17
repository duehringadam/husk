class_name ContextualPopUp
extends Control

@onready var message_text: Label = %messageText
@onready var confirm: Button = %Confirm
@onready var tween_box: PanelContainer = %tweenBox
@onready var open: AudioStreamPlayer = $open
@onready var close: AudioStreamPlayer = $close

var popup_tween: Tween
var is_enabled: bool = false

func _ready() -> void:
	pass

func set_popup_text(message: String, button_message: String = "OK"):
	message_text.text = message
	confirm.text = button_message

func show_popup():
	if is_enabled: 
		return
	if popup_tween:
		popup_tween.kill()
	self.show()
	tween_box.process_mode = Node.PROCESS_MODE_INHERIT
	open.play()
	confirm.grab_focus()
	popup_tween = create_tween()
	popup_tween.finished.connect(_on_tween_finished)
	popup_tween.set_parallel()
	popup_tween.tween_property(tween_box, "offset_transform_position", Vector2(0,-30), .25)\
	.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	popup_tween.tween_property(tween_box, "modulate:a", 1.0, .1)

func hide_popup():
	if !is_enabled: 
		return
	if popup_tween:
		popup_tween.kill()
	close.play()
	popup_tween = create_tween()
	popup_tween.finished.connect(_on_tween_finished)
	popup_tween.set_parallel()
	popup_tween.tween_property(tween_box, "offset_transform_position", Vector2(0,30), .25)\
	.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	popup_tween.tween_property(tween_box, "modulate:a", 0, .1)
	await popup_tween.finished
	tween_box.process_mode = Node.PROCESS_MODE_DISABLED

func activate():
	if is_enabled:
		hide_popup()
	else:
		show_popup()
	is_enabled = !is_enabled

func _on_confirm_pressed() -> void:
	hide_popup()

func _on_tween_finished():
	popup_tween.kill()
