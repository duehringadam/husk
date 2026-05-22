@tool
extends Control

@export var background_color: Color
@export var line_color: Color

@export var inner_radius: int = 64
@export var outer_radius: int = 256
@export var line_width: int = 4

@export var options: Array[item] = []
@export var selected_option: item

func _draw() -> void:
	draw_circle(Vector2.ZERO, outer_radius, background_color)
	draw_arc(Vector2.ZERO, inner_radius,0, TAU, 256, line_color, line_width, true)
	
	if len(options) > 1:
		for i in range(len(options)):
			var rads = TAU * i / (len(options))
			var point = Vector2.from_angle(rads)
			draw_line(point * inner_radius, point * outer_radius, line_color, line_width,true)


func _process(delta: float) -> void:
	queue_redraw()
