class_name SelectBox
extends Box

static func New(_position: Vector3i, _level: Level, _state:BoxState=SelectBoxState.new()) -> SelectBox:
	var _box = baseNew(preload("res://assets/grid/objects/box/selectBox/selectBox.tscn").instantiate(), _position, _level, _state)
	_box.state.positionOffset = Vector3(0, 0.5, 0)
	baseNewEnd(_box)
	return _box

func _ready():
	if getLevelFile() in game.levelData and game.levelData[getLevelFile()].won: state.won = true
	%number.text = state.levelText
	%number.outline_modulate.a = 1 if state.won else 0

func getHoverTitleText(): return "Box[Select]"
func getHoverBodyText():
	return super()\
	+ "\nLevel:" + levelNames()\
	+ ("\nCleared" if state.won else "")

func levelNames() -> String: return game.LEVEL_NAMES[getLevelFile()]
func getLevelFile() -> String: return state.defaultSet + "/" + state.levelFile
