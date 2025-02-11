class_name Box
extends Node3D

var level: Level
var state: ObjectState

static func New(_position, _level) -> Box:
	var _box = preload("res://assets/grid/objects/box/box.tscn").instantiate()
	_box.level = _level
	_box.state = ObjectState.new(_position, 0)
	_box.position = _box.state.getPositionAsVector()
	_box.rotation = _box.state.getRotationAsVector()
	return _box
