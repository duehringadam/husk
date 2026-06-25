extends Offhand

@export var knife: PackedScene

var is_active: bool = false
var camera: Camera3D
func _ready() -> void:
	pass
	
func activate():
	if !is_active:
		is_active = true

func deactivate():
	pass

func _physics_process(delta: float) -> void:
	camera = Global.player.camera

func throw():
	if is_active:
		var knife_projectile = knife.instantiate()
		knife_projectile.transform.basis = Global.player.camera.global_transform.basis
		get_tree().current_scene.add_child(knife_projectile)
		knife_projectile.global_position = camera.global_position
		var throw_direction = -camera.global_transform.basis.z.normalized()
		knife_projectile.apply_central_impulse(throw_direction * 50)
		is_active = false
