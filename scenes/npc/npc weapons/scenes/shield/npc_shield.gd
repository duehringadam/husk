class_name npc_shield
extends npc_weapon_scene
@onready var raise_shield: AudioStreamPlayer3D = $"raise shield"
@onready var block_sfx: AudioStreamPlayer3D = $block

func _ready() -> void:
	while owner == null:
		await get_tree().process_frame
	var hurtbox = get_parent().get_parent().find_children("*","enemy_multiple_collision_hurtbox_component", true, false)[0]
	hurtbox.connect("damage_blocked", block)
	
func activate():
	raise_shield.pitch_scale = randf_range(0.8,1.2)
	raise_shield.play()
	
func deactivate():
	raise_shield.pitch_scale = randf_range(0.8,1.2)
	raise_shield.play()

func block():
	block_sfx.pitch_scale = randf_range(0.8,1.2)
	block_sfx.play()
