class_name Gate
extends GameObject

static func New(_position: Vector3i, _level: Level, _state:=ObjectState.new()) -> Gate:
	var _gate = baseNew(preload("res://assets/grid/objects/gate/gate.tscn").instantiate(), _position, _level, _state)
	baseNewEnd(_gate)
	return _gate
