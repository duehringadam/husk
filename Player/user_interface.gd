extends Control

var can_open: bool = true
var inventory_open: bool = false
@onready var dialogue_container: PanelContainer = $DialogueContainer
@onready var dialogue: RichTextLabel = $DialogueContainer/DialogueMargin/Dialogue
@onready var animation_player: AnimationPlayer = $DialogueContainer/AnimationPlayer
@onready var item_container: PanelContainer = $uiMargin/itemContainer
@onready var inventory: PanelContainer = $uiMargin/inventory

func _ready() -> void:
	SignalBus.dialogue_interact.connect(show_dialogue_box)
	SignalBus.interact_close.connect(close_dialogue_box)
	SignalBus.item_interact.connect(show_item_box)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		inventory_menu()
	
func inventory_menu():
	if inventory_open:
		inventory.close_inventory()
	else:
		inventory.open_inventory()

	inventory_open = !inventory_open

func show_item_box(item_show: item):
	item_container.show()
	item_container.timer.start()

func show_dialogue_box(dialogue_text: Array, duration: float, dialogue_sound: AudioStream, dialogue_position: Vector3):
	if !can_open:
		return
	dialogue_container.show()
	animation_player.play("dialogue_Show")
	dialogue.dialogue(dialogue_text, duration, dialogue_sound, dialogue_position)
	can_open = false

func close_dialogue_box():
	can_open = true
	animation_player.play("dialogue_hide")
	dialogue.text = ""
	dialogue.dialoguetimer.stop()
	await animation_player.animation_finished
	dialogue_container.hide()
	dialogue.visible_ratio = 0.0
