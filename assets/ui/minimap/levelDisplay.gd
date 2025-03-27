@tool
class_name LevelDisplay
extends PanelContainer

var game : Game

@export var level : String:
	set(value):
		level = value
		%Label.text = Game.LEVEL_INFO[value][0] if value in Game.LEVEL_INFO else Level.generateUnknownLevelId(value)

static func New(_level:String, _position:Vector2):
	var object: LevelDisplay = preload("res://assets/ui/minimap/levelDisplay.tscn").instantiate()
	object.level = _level
	object.position = _position
	return object

func _ready():
	if !Engine.is_editor_hint():
		game = get_node("/root/game")

func _mouseEntered() -> void:
	if !Engine.is_editor_hint(): game.minimapHover = self


func _mouseExited() -> void:
	if !Engine.is_editor_hint() and game.minimapHover == self: game.minimapHover = null
