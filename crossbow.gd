extends Weapon

func _ready() -> void:
	state_chart.set_expression_property("can_attack", true)
	SignalBus.connect("secondary_active", secondary_active)
	animation_player.play("equip",-1,1)

func secondary_active(value:bool):
	secondary_active_bool = value

func _on_damage_component_body_entered(body: Node3D) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("attack_primary") && !secondary_active_bool:
			state_chart.send_event("shoot")
		if event.is_action_pressed("attack_secondary") && !secondary_active_bool:
			state_chart.send_event("block")

func _on_damage_component_area_entered(area: Area3D) -> void:
	pass

func block():
	animation_player.play("block")
	AudioManager.play_sound(load("res://sfx/hit-tree-01-266310.mp3"),mesh.global_position,20.0)
	await animation_player.animation_finished
	animation_player.play("block",-1,-1,true)
