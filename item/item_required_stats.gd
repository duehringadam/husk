class_name ItemRequiredStat
extends Resource

enum ItemRequiredStatName {
	VIGOR,
	STRENGTH,
	DEXTERITY,
	WILL,
	INTELLIGENCE,
	FAITH
}

@export var stat_type : ItemRequiredStatName
@export var value : int = 0
