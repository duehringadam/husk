class_name npc_bow
extends npc_weapon_scene
@onready var animation_player: AnimationPlayer = $Armature/AnimationPlayer


func activate():
	animation_player.play("draw")

func deactivate():
	damage_component.monitorable = false
	damage_component.monitoring = false
