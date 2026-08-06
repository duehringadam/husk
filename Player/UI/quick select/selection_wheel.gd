@tool
extends Control

const SPRITE_SIZE = Vector2(32,32)

@export var active: bool = false

@export var background_color: Color
@export var line_color: Color
@export var highlight_color: Color

@export var inner_radius: int = 64
@export var outer_radius: int = 256
@export var line_width: int = 4

@export var options: Array[item] = []

@export var selected_option: int = 0

func _draw() -> void:
	var offset = SPRITE_SIZE/ -2
	draw_circle(Vector2.ZERO, outer_radius, background_color)
	draw_arc(Vector2.ZERO, inner_radius,0, TAU, 128, line_color, line_width, true)
	
	if len(options) >= 3:
		for i in range(len(options) -1):
			var rads = TAU * i / ((len(options) -1))
			var point = Vector2.from_angle(rads)
			draw_line(point * inner_radius, point * outer_radius, line_color, line_width, true)
			
		if selected_option == 0:
			draw_circle(Vector2.ZERO, inner_radius, highlight_color)
			
		#draw center
		draw_texture_rect(options[0].item_icon,
		Rect2(offset,SPRITE_SIZE),
		false)
		
		
		
		for i in range(1, len(options)):
			var start_rads = (TAU * (i-1))/ (len(options) - 1)
			var end_rads = (TAU * i ) / (len(options) -1)
			var mid_rads = (start_rads + end_rads) /2.0 * -1
			var radius_mid = (inner_radius + outer_radius) / 2.0
			
			var draw_pos = radius_mid * Vector2.from_angle(mid_rads) + offset
			
			if selected_option == i:
				var points_per_arc = 32
				var points_inner = PackedVector2Array()
				var points_outer = PackedVector2Array()
				
				for j in range(points_per_arc+1):
					var angle = start_rads + j * (end_rads - start_rads) / points_per_arc
					points_inner.append(inner_radius * Vector2.from_angle(TAU-angle))
					points_outer.append(outer_radius * Vector2.from_angle(TAU-angle))
				
				points_outer.reverse()
				draw_polygon(
					points_inner + points_outer,
					PackedColorArray([highlight_color])
				)
			
			draw_texture_rect(options[i].item_icon,
			Rect2(draw_pos,SPRITE_SIZE),
			false)

func open():
	self.show()
	$open.play()
	active = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GamePiecesEventBus.emit_signal("camera_lock_requested",true)
	var tween = get_tree().create_tween()
	#tween.tween_property(self,"rotation_degrees",0,.1).set_trans(Tween.TRANS_SINE)
	tween.set_parallel()
	tween.tween_property(self, "scale", Vector2(1,1), .1).set_trans(Tween.TRANS_SINE)

func close():
	active = false
	$open.play()
	var tween = get_tree().create_tween()
	GamePiecesEventBus.emit_signal("camera_lock_requested",false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#tween.tween_property(self,"rotation_degrees",-45,.1).set_trans(Tween.TRANS_SINE)
	tween.set_parallel()
	tween.tween_property(self, "scale", Vector2(.5,.5), .1).set_trans(Tween.TRANS_SINE)
	await tween.finished
	self.hide()
	options[0] = options[selected_option]
	return options[selected_option]

func _process(delta: float) -> void:
	if !active: return
	
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()
	
	if mouse_radius < inner_radius:
		selected_option = 0
	else:
		var mouse_rads = fposmod(mouse_pos.angle() * -1, TAU)
		selected_option = ceil((mouse_rads / TAU) * (len(options) -1))
		
	
	queue_redraw()
