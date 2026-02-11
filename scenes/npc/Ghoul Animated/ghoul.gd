extends npc

@export var patrol_positions: Array[Node3D]

@onready var ghoul_parent: Node3D = %Skeleton3D
@onready var aggro_look_at: LookAtModifier3D = $Ghoul/Armature/Skeleton3D/aggroLookAt
@onready var stance_component: StanceComponent = $StanceComponent

var timer: float = 0.0
var search_position : Vector3

func _ready() -> void:
	animation_tree.active = true
	if hurtboxes:
		for i in hurtboxes:
			if !i.is_connected("damage_taken", _on_hurtbox_component_damage_taken):
				i.connect("damage_taken", _on_hurtbox_component_damage_taken)

func _on_hurtbox_component_damage_taken(actual: float, source: DamageComponent, hit_dir: Vector3) -> void:
	animation_tree.set("parameters/conditions/flinch", true)
	if source.source is npc: 
			target = source.source
	if source.source == Global.player:
			target = source.source
	
	get_tree().create_timer(.1).timeout.connect(func(): animation_tree.set("parameters/conditions/flinch", false))
	if hurtboxes:
		for i in hurtboxes:
			if is_instance_valid(i):
				i.invulnerability(i.invulnerability_duration)

func fall():
	state_chart.send_event("knocked_down")
	physical_bone_simulator.physical_bones_start_simulation()
	SPEED = 0
	collision_layer = 0
	
func _on_health_component_died() -> void:
	fall()
	state_chart.send_event("dead")

func head_lost(value: bool)-> void:
	if !value:
		health_component.modify_health(-999)

func _on_stance_component_stance_broken() -> void:
	pass

func _on_bones_severed(bones: Array) -> void:
	for i in bones:
		if i.to_lower().contains("upperarm_r"):
			right_arm = false
		if i.to_lower().contains("upperarm_l"):
			left_arm = false
		if i.to_lower().contains("thigh"):
			leg_attached = false
		if i.to_lower().contains("head"):
			head_attached = false


func _on_vision_area_aggro_changed(aggro_amount: float, aggro_node: Node3D) -> void:
	if aggro_amount >= 1.0:
		state_chart.send_event("attack")
		target = aggro_node
		return
	if aggro_amount >= .5 && aggro_amount < .7:
		state_chart.send_event("search")
		search_position = aggro_node.global_position
		return


func _on_stance_component_stance_changed(amount: float, new_value: float, source: DamageComponent) -> void:
	if stance_component:
		if abs(amount) >= stance_component.max_stance/2:
			state_chart.set_expression_property("knockback_source", source)
			state_chart.send_event("knocked_back")
		if abs(amount) >= stance_component.max_stance:
			state_chart.set_expression_property("knockback_source", source)
			state_chart.send_event("knocked_down")
			
func _update_target(value: Node3D):
	target = value
	if value == null: return
	
	if value is npc:
		aggro_look_at.target_node = target.get_path()
		state_chart.send_event("attack")
		
	if value is Player:
		aggro_look_at.target_node = Global.player.enemy_look_at.get_path()
		state_chart.send_event("attack")
