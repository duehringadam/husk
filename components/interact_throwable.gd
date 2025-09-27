class_name throwable_object
extends interact

var interactable: bool = false
var carried: bool = false
var player_close :bool = false

@export var throwable_mesh: MeshInstance3D
@export var throwable: RigidBody3D
@export var interact_area: Area3D
@export var damage_component: DamageComponent
@export var shattered_mesh: PackedScene
@export var break_sound: AudioStream

const ROTATION_AMOUNT_REDUCTION := 30


func _ready():
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && interactable && player_close:
		Global.player.carry_transform.remote_path = self.get_path()
		throwable_mesh.layers = 2
		carried = true
		throwable.freeze = true
		SignalBus.interact_close.emit()
	if carried and event.is_action_pressed("attack_primary"):
		throw(-Global.player.camera.global_transform.basis.z.normalized(),30)
	if carried and event.is_action_pressed("attack_secondary"):
		drop()

func throw(throw_dir:Vector3, throw_force: int):
	damage_component.monitorable = true
	damage_component.monitoring = true
	throwable.freeze = false
	Global.player.carry_transform.remote_path = ""
	throwable_mesh.layers = 1
	carried = false
	throwable.apply_central_impulse(throw_dir * throw_force)
	throwable.apply_torque_impulse(throw_dir/ROTATION_AMOUNT_REDUCTION)
	
func drop():
	throwable.freeze = false
	Global.player.carry_transform.remote_path = ""
	throwable_mesh.layers = 1
	carried = false

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		player_close = false
		SignalBus.interact_close.emit()

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		player_close = true

func _on_damage_component_damage_dealt(types: Dictionary[DamageTypes.DAMAGE_TYPES, float], actual: float, target: hurtbox_component) -> void:
	if shattered_mesh != null:
		break_object()
	if throwable.linear_velocity.length() > 3:
		if target.get_parent() is NPC:
			target.get_parent().fall(Vector3.FORWARD)


func _on_rigidbody_entered(body: Node) -> void:
	if throwable.linear_velocity.length() > 4 and body.collision_layer == 2:
		if shattered_mesh != null:
			break_object()

func break_object():
	var shattered_mesh_add = shattered_mesh.instantiate()
	get_tree().current_scene.add_child(shattered_mesh_add)
	shattered_mesh_add.global_transform = self.global_transform
	shattered_mesh_add.break_mesh(throwable.linear_velocity, throwable_mesh.get_surface_override_material(0))
	AudioManager.play_sound(break_sound, self.global_position, 0)
	get_tree().create_timer(.1).timeout.connect(func(): self.queue_free())


func _on_health_component_died() -> void:
	break_object()
