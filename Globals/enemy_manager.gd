extends Node

signal enemy_combat_target_changed(name: String, source: Variant, target_max_hp: float, target_current_hp: float)
signal enemy_combat_target_take_damage(amount: float, source: Variant)

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
