extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: hurtbox_component = $hurtbox_component
@onready var health_component: HealthComponent = $HealthComponent

func _ready():
	animation_player.play("Idle")


func _on_health_component_died() -> void:
	queue_free()


func _on_hurtbox_component_damage_taken(amount: float, actual: float, source: DamageComponent) -> void:
	var hit_particles = hurtbox.damage_particles.instantiate()
	get_tree().current_scene.add_child(hit_particles)
	hit_particles.global_position = hurtbox.global_position
	hit_particles.emitting = true
