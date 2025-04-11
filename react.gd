extends ActionLeaf

var play_anim: bool = true

func tick(actor,blackboard):
	if play_anim:
		play_anim = false
		actor.SPEED = 0
		actor.animation_player.play("metarig|hit reaction",-1,1)
	
	if not actor.animation_player.is_playing():
		play_anim = true
		actor.SPEED = 1.5
		return SUCCESS
	return RUNNING
