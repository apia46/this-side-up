class_name SelectBox
extends Box

@onready var game = get_node("/root/game")

static func New(_position: Vector3i, _level: Level, _state:BoxState=SelectBoxState.new()) -> SelectBox:
	var _box = baseNew(preload("res://assets/grid/objects/selectBox/selectBox.tscn").instantiate(), _position, _level, _state)
	_box.state.positionOffset = Vector3(0, 0.5, 0)
	baseNewEnd(_box)
	return _box

func _ready():
	%number.text = state.levelText
	%number.outline_modulate.a = 1 if state.levelFile in game.levelData and game.levelData[state.levelFile].won else 0
