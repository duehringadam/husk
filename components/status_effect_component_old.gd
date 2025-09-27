extends Node

signal status_applied (statuses: Array[Global.STATUS_TYPE], application_amount: float)
signal status_ended

@export var status_effects: Array[Global.STATUS_TYPE]
@export var application_amount: float = 0.0

var source
var burning_particles = preload("res://fire_particles.tscn")
var burn_mix = preload("res://shaders/burn_material.tres")
var blood_mix = preload("res://blood_buildup.tres")

func _ready() -> void:
	SignalBus.connect("status_ended", clear_status)

func apply_status(damage_type: DamageTypes.DAMAGE_TYPES, _source: hurtbox_component):
	match damage_type:
		DamageTypes.DAMAGE_TYPES.FIRE:
			if status_effects.has(Global.STATUS_TYPE.BURNING):
				return
			else:
				status_effects.append(Global.STATUS_TYPE.BURNING)
				source = _source
				get_tree().create_timer(.5).timeout.connect(add_fire)
		DamageTypes.DAMAGE_TYPES.SLASH:
			if status_effects.has(Global.STATUS_TYPE.BLEEDING):
				return
			else:
				status_effects.append(Global.STATUS_TYPE.BLEEDING)
				source = _source
				get_tree().create_timer(.5).timeout.connect(add_bleed)
				
func add_fire():
	for child in self.owner.get_children(true):
		if child is MeshInstance3D:
			if child.get_surface_override_material(0).next_pass == null:
				var burn_mix_unique = burn_mix.duplicate()
				child.get_surface_override_material(0).next_pass = burn_mix_unique
				self.owner.mesh_particle_component.mesh = child
		if child is Skeleton3D:
			for c in child.get_children(true):
				if c is MeshInstance3D:
					if c.get_surface_override_material(0).next_pass == null:
						var burn_mix_unique = burn_mix.duplicate()
						c.get_surface_override_material(0).next_pass = burn_mix_unique
						self.owner.mesh_particle_component.mesh = c
	emit_signal("status_applied", status_effect, application_amount)

func add_bleed():
	for child in self.owner.get_children(true):
		if child is MeshInstance3D:
			if child.get_surface_override_material(0).next_pass == null:
				var blood_mix_unique = blood_mix.duplicate()
				child.get_surface_override_material(0).next_pass = blood_mix_unique
				self.owner.mesh_particle_component.mesh = child
		if child is Skeleton3D:
			for c in child.get_children(true):
				if c is MeshInstance3D:
					if c.get_surface_override_material(0).next_pass == null:
						var blood_mix_unique = blood_mix.duplicate()
						c.get_surface_override_material(0).next_pass = blood_mix_unique
						self.owner.mesh_particle_component.mesh = c
						
	emit_signal("status_applied", status_effect, application_amount)

	
func clear_status(status: Global.STATUS_TYPE):
	if status_effects.has(status):
		status_effects.erase(status)
		emit_signal("status_ended")
