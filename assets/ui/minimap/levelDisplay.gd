@tool
class_name LevelDisplay
extends PanelContainer

var game : Game
var hovered := false

@export var level : String:
	set(value):
		level = value
		levelText = Game.LEVEL_INFO[value][0] if value in Game.LEVEL_INFO else Level.generateUnknownLevelId(value)
		%Label.text = levelText
var levelText : String

static func New(_level:String, _position:Vector2):
	var object: LevelDisplay = preload("res://assets/ui/minimap/levelDisplay.tscn").instantiate()
	object.level = _level
	object.position = _position
	return object

func _ready():
	if !Engine.is_editor_hint():
		game = get_node("/root/game")
		if !is_connected("mouse_entered", mouse_entered): connect("mouse_entered", mouse_entered)
		if !is_connected("mouse_exited", mouse_exited): connect("mouse_exited", mouse_exited)
		reevaluate()

func reevaluate():
	print("level ", level, level in game.levelData)
	visible = levelText[-1] not in "?!" or level in game.levelData
	%winMark.visible = level in game.levelData and game.levelData[level].won

func mouse_entered() -> void:
	create_tween().tween_property(%border, "modulate", Color(1,1,1,1), 0.15)
	if !Engine.is_editor_hint():
		hovered = true
		game.minimapHover = self

func mouse_exited() -> void:
	create_tween().tween_property(%border, "modulate", Color(1,1,1,0), 0.15)
	if !Engine.is_editor_hint():
		hovered = false
		if game.minimapHover == self: game.minimapHover = null
