extends Polygon2D

var edges = 6
@export var radius = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var delta_radians = 2*PI / edges
	var new_polygon: PackedVector2Array
	for edge in edges:
		new_polygon.append(Vector2(sin(edge * delta_radians), cos(edge * delta_radians)) * radius)
	polygon = new_polygon


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
