extends Camera3D
@export var randomStrength: float = 0.05
@export var shakeFade: float = 5.0
@export var hurtbox: hurtbox_component

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var offset
###################
# lerps screenshake by randomstrength and fade amount
###################
	
	
func _ready() -> void:
	if !hurtbox.is_connected("damage_taken", _on_damage_taken):
		hurtbox.connect("damage_taken", _on_damage_taken)
		
func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shakeFade * delta)
		offset = randomOffset()
		h_offset = offset.x
		v_offset = offset.y
		
###################
# this is called when you want to apply screen shake to camera
###################
func apply_shake(_shake_strength: float = 0.05):
	shake_strength = _shake_strength
	
func _on_damage_taken(amount: float, actual: float, source: DamageComponent):
	if amount >0:
		apply_shake()
	
###################
# random offset to shake camera by
###################
func randomOffset():
	return Vector2(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))
