extends Node

var leaders : Array[npc]
var enemies_in_combat : Array[npc]

func set_leaders(enemy: npc):
	if leaders.size() < 3:
		leaders.append(enemy)
	
	for i in leaders:
		i.is_leader = true

func set_enemies_in_combat(enemy: npc):
	enemies_in_combat.append(enemy)
	
	for i in enemies_in_combat:
		set_leaders(i)
