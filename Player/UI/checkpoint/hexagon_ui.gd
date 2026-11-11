extends Polygon2D

@export var radius = 100
@export var font: Font
@export var font_size: int
var attributes = ["VGR", "END", "STR", "DEX", "INT", "FTH"]
var delta_radians = 2*PI / 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_polygon: PackedVector2Array
	for i in 6:
		var att_scale = randf()
		new_polygon.append(Vector2(sin(i * delta_radians), cos(i * delta_radians)) * radius * att_scale)
		var new_label = Label.new()
		add_child(new_label)
		new_label.text = attributes[i]
		new_label.add_theme_font_override("font", font)
		new_label.add_theme_font_size_override("size", font_size)
		new_label.offset_transform_enabled = true
		new_label.offset_transform_position = Vector2(sin(i * delta_radians), cos(i * delta_radians)) * radius * 1.1 - new_label.size/2.0
		
	polygon = new_polygon


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _draw() -> void:
	
	for i in 6:
		#draw border
		draw_line(Vector2(sin(i * delta_radians), cos(i * delta_radians)) * radius, Vector2(sin((i+1) * delta_radians), cos((i+1) * delta_radians)) * radius, Color.WHITE, 5.0, true)
		#draw divider
		draw_line(Vector2.ZERO, Vector2(sin(i * delta_radians), cos(i * delta_radians)) * radius, Color.WHITE, -1, true)
		#draw sub lines
		var relative_line = Vector2(5, 0).rotated(-i * delta_radians)
		for j in range(0,10):
			var center_point = Vector2(sin(i * delta_radians), cos(i * delta_radians)) * radius * (j/10.0)
			draw_line(center_point + relative_line, center_point - relative_line, Color.WHITE, -1, true)
