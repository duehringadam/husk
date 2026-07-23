extends Node

@export var source_npc: CharacterBody3D
@export var animation_tree: AnimationTree
@export var state_chart: StateChart
@export var distance: float

@onready var ledge_check: ShapeCast3D = %ledgeCheck
@onready var ledge_check_parent: Node3D = %ledgeCheckParent

var knockback_source
func _ready() -> void:
	animation_tree["parameters/playback"].connect("state_finished", _anim_finished)
	
func _on_knocked_back_state_entered() -> void:
	source_npc.SPEED =0
	animation_tree.set("parameters/conditions/hit", true)
	var kb_source: Node3D = state_chart.get_expression_property("knockback_source")
	if kb_source:
		var force_direction: Vector2 = Vector2(kb_source.global_position.z - ledge_check_parent.global_position.z, kb_source.global_position.x - ledge_check_parent.global_position.x)
		ledge_check_parent.rotation.y = force_direction.angle()
	
	if ledge_check.is_colliding():
		for i in ledge_check.get_collision_count():
			var collider = ledge_check.get_collider(i)
			if !is_instance_valid(collider): return
			if collider.owner.is_in_group("traps"):
				if kb_source:
					knockback_source = kb_source
					var kb :Vector3 = ledge_check.global_position - source_npc.global_position
					var kb_dir = kb.normalized()
					kb_dir.y = 0
					var kb_amount = kb_dir
					source_npc.velocity = kb_amount * (distance/5)
					animation_tree.set("parameters/conditions/hit", false)
					state_chart.send_event("knocked_down")
	else:
		if kb_source:
					var kb :Vector3 = ledge_check.global_position - source_npc.global_position
					var kb_dir = kb.normalized()
					kb_dir.y = 0
					var kb_amount = kb_dir
					source_npc.velocity = kb_amount
					animation_tree.set("parameters/conditions/hit", false)
					state_chart.send_event("knocked_down")
	
	if kb_source.source:
		var kb :Vector3 = ledge_check.global_position - source_npc.global_position
		var kb_dir = kb.normalized()
		kb_dir.y = 0
		var kb_amount = kb_dir
		source_npc.velocity = kb_amount * distance
		knockback_source = kb_source
	else:
		var kb :Vector3 = ledge_check.global_position - source_npc.global_position
		var kb_dir = kb.normalized()
		kb_dir.y = 0
		var kb_amount = kb_dir * distance
		source_npc.velocity = kb_amount
		knockback_source = kb_source


func _on_knocked_back_state_exited() -> void:
	pass # Replace with function body.


func _on_knocked_back_state_physics_processing(delta: float) -> void:
	if ledge_check.is_colliding():
		for i in ledge_check.get_collision_count():
			var collider = ledge_check.get_collider(i)
			if collider.owner.is_in_group("traps"):
				state_chart.send_event("knocked_down")
	else:
		state_chart.send_event("knocked_down")
		
		
func _anim_finished(state: StringName):
	if state.to_lower().contains("hit"):
		animation_tree.set("parameters/conditions/hit", false)
		state_chart.send_event("resume")
