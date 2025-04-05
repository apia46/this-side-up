@tool
class_name LevelDisplay
extends PanelContainer

var game : Game
var hovered := false
var visited := false

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

func _process(delta):
	if hovered and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and !game.loadingLevel and visited:
		%confirm.value += delta * 100
	else:
		%confirm.value -= delta*500
	if !game.loadingLevel and %confirm.value == 100:
		game.level.changeLevel(level, "enter")

func reevaluate():
	visited = level in game.levelData
	modulate.a = 1.0 if visited else 0.5
	visible = levelText[-1] not in "?!" or visited
	%winMark.visible = visited and game.levelData[level].won

func mouse_entered() -> void:
	if !visited: return
	create_tween().tween_property(%border, "modulate", Color(1,1,1,1), 0.15)
	if !Engine.is_editor_hint():
		hovered = true
		game.minimapHover = self

func mouse_exited() -> void:
	if !visited: return
	create_tween().tween_property(%border, "modulate", Color(1,1,1,0), 0.15)
	if !Engine.is_editor_hint():
		hovered = false
		if game.minimapHover == self: game.minimapHover = null
