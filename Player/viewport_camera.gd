extends Camera3D

@export var main_camera: Camera3D
@export var randomStrength: float = 3.0
@export var shakeFade: float = 5.0
@export var hurtbox: hurtbox_component

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var offset

func _ready() -> void:
	if !hurtbox.is_connected("damage_taken", _on_hurtbox_component_damage_taken):
		hurtbox.connect("damage_taken", _on_hurtbox_component_damage_taken)
	environment = get_world_3d().environment
	
###################
# lerps screenshake by randomstrength and fade amount
###################

func _process(delta: float) -> void:
	global_transform = main_camera.global_transform
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shakeFade * delta)
		offset = randomOffset()
		h_offset = offset.x
		v_offset = offset.y
		
###################
# this is called when you want to apply screen shake to camera
###################
func apply_shake():
	shake_strength = randomStrength
	
###################
# random offset to shake camera by
###################
func randomOffset():
	return Vector2(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))


func _on_hurtbox_component_damage_taken(actual: float, source: DamageComponent, hit_dir: Vector3) -> void:
	if actual >0:
		apply_shake()
