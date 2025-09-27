extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var spell_projectile: PackedScene
@onready var target_ik_left: Node3D = $TargetIKLeft
@export var ray: RayCast3D

func _ready() -> void:
	animation_player.play("fire_spell_idle")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_secondary"):
		animation_player.play("fire_spell_attack")
		var screen_center = get_viewport().size/2
		var origin = Global.player.camera.project_ray_origin(screen_center)
		var end = origin + Global.player.camera.project_ray_normal(screen_center) * 15
		ray.look_at(end)
		AudioManager.play_sound(load("res://sfx/fire-magic-5-378639.mp3"), self.global_position, 0)
		if ray.is_colliding():
			var spell_projectile_add = spell_projectile.instantiate()
			get_tree().current_scene.add_child(spell_projectile_add)
			spell_projectile_add.global_position = ray.get_collision_point()
			AudioManager.play_sound(load("res://sfx/whoosh-flame-388763.wav"),ray.get_collision_point(),0)
			if global_position.distance_to(Global.player.global_position) < 5:
				Global.player.camera.apply_shake(0.06)
		else:
			var spell_projectile_add = spell_projectile.instantiate()
			get_tree().current_scene.add_child(spell_projectile_add)
			AudioManager.play_sound(load("res://sfx/whoosh-flame-388763.wav"),end,0)
			spell_projectile_add.global_position = end
		await animation_player.animation_finished
		animation_player.play("fire_spell_idle")
