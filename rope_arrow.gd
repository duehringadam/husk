extends Projectile

@export var rope_to_create: PackedScene
@onready var rope_raycast: RayCast3D = $ropeRaycast
@onready var remote_transform: RemoteTransform3D = $RemoteTransform3D
@onready var rope_point: Marker3D = $rope_point
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var pin_area: Area3D = $pinArea

var rope

func _ready() -> void:
	add_child(timer)
	timer.wait_time = lifetime
	timer.start()
	timer.timeout.connect(func(): self.queue_free())

func _update_source(value: Node3D):
	source = value
	damage_component.source = source

func _on_damage_component_body_entered(body: Node3D) -> void:
	if body is StaticBody3D:
		$AudioStreamPlayer3D.play()
		rope = rope_to_create.instantiate()
		gpu_trail.visible = false
		if ray_cast_3d.is_colliding():
			var collision_point = ray_cast_3d.get_collision_point()
			pin = true
			call_deferred("reparent",body)
			damage_component.set_deferred("monitorable", false)
			damage_component.set_deferred("monitoring", false)
			pin_area.set_deferred("monitorable", false)
			pin_area.set_deferred("monitoring", false)
			global_position = collision_point
		
		
		if rope_raycast.is_colliding() && rope_point.global_position.distance_to(rope_raycast.get_collision_point()) > 2:
			$rope_sound.play()
			rope.global_transform = rope_point.global_transform
			rope.number_of_segments = rope_point.global_position.distance_to(rope_raycast.get_collision_point())+1
			get_tree().current_scene.add_child(rope)
			rope.collider.get_child(0).shape.size.y = rope_point.global_position.distance_to(rope_raycast.get_collision_point())+1
			rope.ladder_area.get_child(0).shape.size.y = rope_point.global_position.distance_to(rope_raycast.get_collision_point())+1
			rope.collider.global_position = rope_point.global_position
			rope.ladder_area.global_position = rope_point.global_position
			rope.collider.global_position.y = (rope_point.global_position.y + rope_raycast.get_collision_point().y)/2
			rope.ladder_area.global_position.y = (rope_point.global_position.y + rope_raycast.get_collision_point().y)/2

func _process(delta: float) -> void:
	if !pin:
		position += transform.basis * Vector3(0,0,-speed*delta)


func _on_damage_component_damage_dealt(types: Dictionary, actual: float, stance_damage: float, target: hurtbox_component) -> void:
	AudioManager.play_sound($AudioStreamPlayer3D.stream,self.global_position,0)
	damage_component.set_deferred("monitorable", false)
	damage_component.set_deferred("monitoring", false)
