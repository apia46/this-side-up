@tool
class_name LevelDisplay
extends PanelContainer

@export var level : String:
	set(value):
		level = value
		%Label.text = Game.LEVEL_INFO[value][0] if value in Game.LEVEL_INFO else Level.generateUnknownLevelId(value)

static func New(_level:String, _position:Vector2):
	var object: LevelDisplay = preload("res://assets/ui/minimap/levelDisplay.tscn").instantiate()
	object.level = _level
	object.position = _position
	return object
