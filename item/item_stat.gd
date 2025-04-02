class_name ItemStat
extends Resource

#this class represents stats that will be added to the player

enum ItemStatName {
	DAMAGE,
	SPEED,
	REACH,
	STRENGTH_SCALE,
	WILL_SCALE,
	INTELLIGENCE_SCALE,
	FAITH_SCALE
}

@export var stat_type : ItemStatName
@export var value : float = 0
