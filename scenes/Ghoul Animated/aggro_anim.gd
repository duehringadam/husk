extends ActionLeaf

var play_anim := true

func tick(actor: Node, blackboard: Blackboard) -> int:
	if play_anim:
		actor.aggro_activate = false
		actor.SPEED = 0
		actor.animation_tree.set("parameters/conditions/aggro", true)
		await actor.animation_tree.animation_finished
		play_anim = false
		actor.animation_tree.set("parameters/conditions/aggro", false)
		actor.animation_tree.set("parameters/conditions/idle", false)
		actor.animation_tree.set("parameters/conditions/run", true)
		actor.animation_tree.set("parameters/conditions/walk", false)
		return SUCCESS
		
	return RUNNING
