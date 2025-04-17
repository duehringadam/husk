extends PanelContainer

@onready var item_margin: MarginContainer = $itemMargin
@onready var h_box_container: HBoxContainer = $itemMargin/HBoxContainer
@onready var rich_text_label: RichTextLabel = $itemMargin/HBoxContainer/RichTextLabel
@onready var texture_rect: TextureRect = $itemMargin/HBoxContainer/TextureRect
@onready var timer: Timer = $Timer



func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && timer.time_left <= 0:
		visible = false
