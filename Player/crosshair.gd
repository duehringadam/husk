extends CenterContainer

@export var DOT_RADIUS: float = 1.0
@export var DOT_COLOR: Color = Color.WHITE
@export var RETICLE_LINES: Array[Line2D]
@export var PLAYER_CONTROLLER: CharacterBody3D
@export var RETICLE_SPEED: float = 0.25
@export var RETICLE_DISTANCE: float = 6.0


func _process(delta: float) -> void:
	adjust_reticle_lines()
	
func _ready() -> void:
	queue_redraw()

func _draw():
	draw_circle(Vector2(0,0),DOT_RADIUS,DOT_COLOR)

func adjust_reticle_lines():
	var mouse_movement = Input.get_last_mouse_velocity().normalized()
	var vel = PLAYER_CONTROLLER.get_real_velocity()
	var pos = Vector2(0,0)
	var speed = vel.length()
	
	var input_dir = PLAYER_CONTROLLER.input_dir
	
	#RETICLE_LINES[0].position = lerp(RETICLE_LINES[0].position, pos + Vector2(0,-speed * RETICLE_DISTANCE),RETICLE_SPEED)
	#RETICLE_LINES[1].position = lerp(RETICLE_LINES[1].position, pos + Vector2(speed * RETICLE_DISTANCE, 0),RETICLE_SPEED)
	#RETICLE_LINES[2].position = lerp(RETICLE_LINES[2].position, pos + Vector2(0, speed * RETICLE_DISTANCE),RETICLE_SPEED)
	#RETICLE_LINES[3].position = lerp(RETICLE_LINES[3].position, pos + Vector2(-speed * RETICLE_DISTANCE,0),RETICLE_SPEED)
	
	if abs(mouse_movement.length()) < 0.3 && input_dir.length() == 0:
		RETICLE_LINES[0]["default_color"] = Color.DIM_GRAY
		RETICLE_LINES[1]["default_color"] = Color.DIM_GRAY
		RETICLE_LINES[2]["default_color"] = Color.DIM_GRAY
		RETICLE_LINES[3]["default_color"] = Color.DIM_GRAY
		
		RETICLE_LINES[0].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		RETICLE_LINES[1].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		RETICLE_LINES[2].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		RETICLE_LINES[3].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		return
	
	if input_dir.z == 1.0:
		RETICLE_LINES[0]["default_color"] = Color.DIM_GRAY
		RETICLE_LINES[1]["default_color"] = Color.DIM_GRAY
		RETICLE_LINES[2]["default_color"] = lerp(Color.DIM_GRAY, Color.WHITE, 1)
		RETICLE_LINES[3]["default_color"] = Color.DIM_GRAY
		
		RETICLE_LINES[0].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		RETICLE_LINES[1].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		RETICLE_LINES[2].scale = lerp(Vector2.ONE,Vector2.ONE*2, RETICLE_SPEED)
		RETICLE_LINES[3].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		return
	
	if input_dir.z == -1.0:
		RETICLE_LINES[0]["default_color"] = lerp(Color.DIM_GRAY, Color.WHITE, 1)
		RETICLE_LINES[1]["default_color"] = Color.DIM_GRAY
		RETICLE_LINES[2]["default_color"] = Color.DIM_GRAY
		RETICLE_LINES[3]["default_color"] = Color.DIM_GRAY
		
		RETICLE_LINES[0].scale = lerp(Vector2.ONE,Vector2.ONE*2, RETICLE_SPEED)
		RETICLE_LINES[1].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		RETICLE_LINES[2].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		RETICLE_LINES[3].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		return
	
	if mouse_movement.x > 0.9:
		RETICLE_LINES[0]["default_color"] = Color.DIM_GRAY
		RETICLE_LINES[1]["default_color"] = lerp(Color.DIM_GRAY, Color.WHITE, 1)
		RETICLE_LINES[2]["default_color"] = Color.DIM_GRAY
		RETICLE_LINES[3]["default_color"] = Color.DIM_GRAY
		
		RETICLE_LINES[0].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		RETICLE_LINES[1].scale = lerp(Vector2.ONE,Vector2.ONE*2, RETICLE_SPEED)
		RETICLE_LINES[2].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		RETICLE_LINES[3].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		return
		
	if mouse_movement.x < -0.9:
		RETICLE_LINES[0]["default_color"] = Color.DIM_GRAY
		RETICLE_LINES[1]["default_color"] = Color.DIM_GRAY
		RETICLE_LINES[2]["default_color"] = Color.DIM_GRAY
		RETICLE_LINES[3]["default_color"] = lerp(Color.DIM_GRAY, Color.WHITE, 1)
		
		RETICLE_LINES[0].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		RETICLE_LINES[1].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		RETICLE_LINES[2].scale = lerp(Vector2.ONE,Vector2.ONE, RETICLE_SPEED)
		RETICLE_LINES[3].scale = lerp(Vector2.ONE,Vector2.ONE*2, RETICLE_SPEED)
		return
	
