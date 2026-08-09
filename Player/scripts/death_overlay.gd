extends ColorRect

@onready var label: Label = $Label

func _ready() -> void:
	material["shader_parameter/factor"] = 0
	label.hide()
