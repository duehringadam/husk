extends Control

@onready var cross_hair: TextureRect = %CrossHair
@onready var interact_prompt: RichTextLabel = %InteractPrompt
@onready var _formatter: PromptFormatter = PromptKenneysFormatter.new()

var gradient = preload("res://Player/player/crosshair_gradient.tres")
var tween: Tween
func _ready() -> void:
	_nothing_interactable()
	SignalBus.connect("player_ready", player_ready)
	get_tree().root.size_changed.connect(queue_redraw)
	

func player_ready():
	InteractionController.current.clear_action_prompts.connect(_nothing_interactable)
	InteractionController.current.display_action_prompts.connect(_something_interactable)


func _nothing_interactable() -> void:
	tween_crosshair(Vector2(0.75,0.25))
	interact_prompt.text = ""

func _something_interactable(object_name: String, actions: Array[Interaction], alt_display: bool) -> void:

	if alt_display:
		tween_crosshair(Vector2(1,0))
		actions = actions.filter(func(a: Interaction) -> bool: return not a.hide_while_grabbed)
	else:
		tween_crosshair(Vector2(1,0))
	
	if actions.is_empty():
		tween_crosshair(Vector2(0.75,0.25))
		interact_prompt.text = ""
		return
	
	interact_prompt.text = "[b]%s[/b]: %s" % [
		object_name,
		", ".join(actions.map(func(a: Interaction) -> String:
		@warning_ignore("redundant_await")
		return "%s to %s" % [await _formatter.format_async(a.control), a.get_display_name()]
		))
	]
	queue_redraw()

func tween_crosshair(value: Vector2):
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.finished.connect(_on_tween_finished)
	tween.tween_property(gradient, "fill_to", value, .1)\
	.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
func _on_tween_finished():
	tween.kill()
