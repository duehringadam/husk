extends Node

@export var source_npc: CharacterBody3D
@export var animation_tree: AnimationTree
@export var state_chart: StateChart
@export var distance: float

@onready var ledge_check: ShapeCast3D = $"../../../../ledgeCheck"

var knockback_source

func _ready() -> void:
	animation_tree["parameters/playback"].connect("state_finished", _anim_finished)

func _on_knocked_back_state_entered() -> void:
	source_npc.SPEED =0
	animation_tree.set("parameters/conditions/stagger", true)
	var kb_source = state_chart.get_expression_property("knockback_source")
	 
	
	if ledge_check.is_colliding():
		for i in ledge_check.get_collision_count():
			var collider = ledge_check.get_collider(i)
			if !is_instance_valid(collider): return
			if collider.owner.is_in_group("traps"):
				if kb_source:
					knockback_source = kb_source
					var kb :Vector3 = kb_source.source.global_position - source_npc.global_position
					var kb_dir = kb.normalized()
					kb_dir.y = 0
					var kb_amount = kb_dir * (distance/5)
					source_npc.velocity = -kb_amount
					await get_tree().create_timer(.5).timeout
					animation_tree.set("parameters/conditions/stagger", false)
					state_chart.send_event("knocked_down")
	else:
		if kb_source:
					var kb :Vector3 = kb_source.source.global_position - source_npc.global_position
					var kb_dir = kb.normalized()
					kb_dir.y = 0
					var kb_amount = kb_dir * (distance/5)
					source_npc.velocity = -kb_amount
					await get_tree().create_timer(.5).timeout
					animation_tree.set("parameters/conditions/stagger", false)
					state_chart.send_event("knocked_down")
	
	if kb_source.source:
		var kb :Vector3 = kb_source.source.global_position - source_npc.global_position
		var kb_dir = kb.normalized()
		kb_dir.y = 0
		var kb_amount = kb_dir * distance
		source_npc.velocity = -kb_amount
		knockback_source = kb_source
	else:
		var kb :Vector3 = kb_source.global_position - source_npc.global_position
		var kb_dir = kb.normalized()
		kb_dir.y = 0
		var kb_amount = kb_dir * distance
		source_npc.velocity = -kb_amount
		knockback_source = kb_source


func _on_knocked_back_state_exited() -> void:
	pass


func _on_knocked_back_state_physics_processing(delta: float) -> void:
	if knockback_source:
		source_npc.rotation.y = lerp_angle(source_npc.rotation.y, atan2(source_npc.global_position.direction_to(knockback_source.global_position).x, source_npc.global_position.direction_to(knockback_source.global_position).z),10*delta)
	if ledge_check.is_colliding():
		for i in ledge_check.get_collision_count():
			var collider = ledge_check.get_collider(i)
			if collider.owner.is_in_group("traps"):
				state_chart.send_event("knocked_down")
	else:
		state_chart.send_event("knocked_down")
		
		
func _anim_finished(state: StringName):
	if state == "KnockedBack" or state == "idleKnockedBack":
		animation_tree.set("parameters/conditions/stagger", false)
		state_chart.send_event("resume")
