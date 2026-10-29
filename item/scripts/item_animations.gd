@tool
class_name ItemAnimations
extends Resource

var idle: String = ""
var equip: String = ""
var attack_1: String = ""
var attack_2: String = ""
var attack_3: String = ""
var heavy_attack: String = ""
var mainhand_lower: String = ""

var block_start: String = ""
var block_hit: String = ""
var block_stun: String = ""

##
## This is what animation plays when you press/hold right click. i.e. shield raise or spell cast
##
var activate: String = ""
##
## This is what animation plays when you release right click. i.e lowering shield, spell ending, or throwing something
##
var deactivate: String = ""
var offhand_idle: String = ""
var offhand_equip: String = ""
var offhand_lower: String = ""
var offhand_block_hit: String = ""
var offhand_block_stun: String = ""
var offhand_cant_use: String = ""

@export_group("Animation Libraries")
##
## Assign a specific animation library resource and it will auto-populate the dropdowns with the available animations
##
@export var target_libraries: Array[AnimationLibrary]:
	set(value):
		target_libraries = value
		notify_property_list_changed()

func _get_animation_dropdown_string() -> String:
	var anim_names: Array[String] = [""] # Empty option means "None"
	for library in target_libraries:
		if library:
			for anim_name in library.get_animation_list():
				if not anim_names.has(anim_name):
					anim_names.append(anim_name)
	return ",".join(anim_names)

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	var anim_hint_string = _get_animation_dropdown_string()
	
	# Mainhand Group
	properties.append({ "name": "Mainhand Animations", "type": TYPE_NIL, "usage": PROPERTY_USAGE_GROUP, "hint_string": "" })
	properties.append({ "name": "idle", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	properties.append({ "name": "equip", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	properties.append({ "name": "mainhand_lower", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	
	# Attack Subgroup
	properties.append({ "name": "Attack Animations", "type": TYPE_NIL, "usage": PROPERTY_USAGE_SUBGROUP, "hint_string": "Mainhand Animations_" })
	properties.append({ "name": "attack_1", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	properties.append({ "name": "attack_2", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	properties.append({ "name": "attack_3", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	properties.append({ "name": "heavy_attack", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	
	# Mainhand Blocking Subgroup
	properties.append({ "name": "Mainhand Blocking", "type": TYPE_NIL, "usage": PROPERTY_USAGE_SUBGROUP, "hint_string": "Mainhand Animations_" })
	properties.append({ "name": "block_start", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	properties.append({ "name": "block_hit", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	properties.append({ "name": "block_stun", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	
	# Offhand Group
	properties.append({ "name": "Offhand Animations", "type": TYPE_NIL, "usage": PROPERTY_USAGE_GROUP, "hint_string": "" })
	properties.append({ "name": "activate", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	properties.append({ "name": "deactivate", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	
	# Offhand Blocking Subgroup
	properties.append({ "name": "offhand_idle", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	properties.append({ "name": "Offhand Blocking", "type": TYPE_NIL, "usage": PROPERTY_USAGE_SUBGROUP, "hint_string": "Offhand Animations_" })
	properties.append({ "name": "offhand_equip", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	properties.append({ "name": "offhand_block_hit", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	properties.append({ "name": "offhand_block_stun", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	properties.append({ "name": "offhand_cant_use", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })
	properties.append({ "name": "offhand_lower", "type": TYPE_STRING, "hint": PROPERTY_HINT_ENUM, "hint_string": anim_hint_string })

	return properties
