extends ActionLeaf

var play_anim: bool = true
@onready var damage_component: DamageComponent = $"../../../../skeleton_fixed/metarig/Skeleton3D/weapon/broken/DamageComponent"

func tick(actor,blackboard):
	if play_anim:
		damage_component.monitoring = true
		damage_component.monitorable = true
		play_anim = false
		actor.SPEED = 1
		actor.animation_player.play("metarig|attack combo")
	if not actor.animation_player.is_playing():
		play_anim = true
		damage_component.monitoring = false
		damage_component.monitorable = false
		return SUCCESS
	return RUNNING
