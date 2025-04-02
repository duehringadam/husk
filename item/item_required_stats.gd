class_name ItemRequiredStat
extends Resource

enum ItemRequiredStatName {
	STRENGTH,
	WILL,
	INTELLIGENCE,
	FAITH
}

@export var stat_type : ItemRequiredStatName
@export var value : int = 0
