class_name mesh_particle_component
extends GPUParticles3D


@export var particle_mesh: Mesh
@export var status_component: status_effect_component
@onready var damage_component: DamageComponent = $DamageComponent
@onready var light: OmniLight3D = $OmniLight3D

var max_health: float
var mesh: MeshInstance3D

func _ready() -> void:
	if status_component != null:
		if !status_component.is_connected("status_applied", _on_status_applied):
			status_component.connect("status_applied", _on_status_applied)
		if !status_component.is_connected("status_ended", _on_status_ended):
			status_component.connect("status_ended", _on_status_ended)
			
	if particle_mesh != null:
		self.set_draw_pass_mesh(1,particle_mesh)
	
	for child in self.owner.get_children(true):
		if child is HealthComponent:
			if !child.is_connected("died", _on_death):
				child.connect("died", _on_death)
			if !child.is_connected("health_changed", _on_damage_taken):
				child.connect("health_changed", _on_damage_taken)
			if !child.is_connected("max_health_changed", _max_health_changed):
				child.connect("health_changed", _max_health_changed)
		
func set_particle_emitter(process_material: ParticleProcessMaterial):
	pass

func _on_status_applied(statuses: Array, application_amount: float) -> void:
	light.light_energy = 1
	emitting = true
	damage_component.monitorable = true
	damage_component.monitoring = true


func _on_status_ended() -> void:
	light.light_energy = 0
	emitting = false
	damage_component.monitorable = false
	damage_component.monitoring = false
	

func _on_damage_taken(amount: float, new_value: float):
	if mesh != null:
		var ratio = (1 - (new_value/max_health))
		if ratio > 0:
			var material = mesh.get_surface_override_material(0).next_pass
			var tween = get_tree().create_tween()
			tween.tween_property(material, "shader_parameter/progress",clampf(material["shader_parameter/progress"]+ratio,0,.45),.5)

func _on_death():
	var material = mesh.get_surface_override_material(0).next_pass
	var tween = get_tree().create_tween()
	tween.tween_property(material, "shader_parameter/progress",clampf(material["shader_parameter/progress"]+1,0,.65),.5)

func _max_health_changed(amount: float, new_value: float):
	max_health = new_value
	
func _on_timer_timeout() -> void:
	SignalBus.emit_signal("status_ended", Global.STATUS_TYPE.BURNING)
	self.queue_free()
