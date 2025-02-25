class_name SelectBox
extends Box

static func New(_position: Vector3i, _level: Level, _state:BoxState=SelectBoxState.new()) -> SelectBox:
	var _box = baseNew(preload("res://assets/grid/objects/selectBox/selectBox.tscn").instantiate(), _position, _level, _state)
	_box.state.positionOffset = Vector3(0, 0.5, 0)
	baseNewEnd(_box)
	return _box

func _ready():
	%number.text = state.levelText
