@tool
class_name LevelDisplay
extends PanelContainer

@onready var game = get_node("/root/game")

@export var level : String:
	set(value):
		level = value
		%Label.text = Game.LEVEL_INFO[value][0] if value in Game.LEVEL_INFO else Level.generateLevelNumber(value)

static func New(_level:String):
	var object: LevelDisplay = preload("res://assets/ui/minimap/levelDisplay.tscn").instantiate()
	object.level = _level
	return object
