class_name SelectBox
extends Box

static func New(_position: Vector3i, _level: Level, _state:BoxState=SelectBoxState.new()) -> SelectBox:
	var _box = baseNew(preload("res://assets/objects/box/selectBox/selectBox.tscn").instantiate(), _position, _level, _state)
	_box.state.positionOffset = Vector3(0, 0.5, 0)
	baseNewEnd(_box)
	return _box

func _ready():
	if getLevelFile() in game.levelData and game.levelData[getLevelFile()].won: state.won = true
	%number.text = state.levelText
	%number.outline_modulate.a = 1 if state.won else 0
	super()

func getHoverTitleText(): return "Box[Select]"
func getHoverBodyText():
	return super()\
	+ "\nLevel" + ("s?:" if len(level.levelData.selectBoxLevels[id]) > 1 else ":") + levelNames()\
	+ ("\nCleared" if state.won else "")

func levelNames() -> String:
	var levels = []
	for _level in level.levelData.selectBoxLevels[id]:
		if _level in game.LEVEL_INFO: levels.append(game.LEVEL_INFO[_level][0])
		else: levels.append(Level.generateUnknownLevelId(_level))
	return ", ".join(levels)
func getLevelFile() -> String: return state.defaultSet + "/" + state.levelFile
