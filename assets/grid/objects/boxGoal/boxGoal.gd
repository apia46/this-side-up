class_name BoxGoal
extends Node3D

var level: Level
var state: ObjectState

static func New(_position: Vector3i, _level: Level) -> BoxGoal:
	var _boxGoal = preload("res://assets/grid/objects/boxGoal/boxGoal.tscn").instantiate()
	_boxGoal.level = _level
	_boxGoal.state = ObjectState.new(_position, 0)
	_boxGoal.position = _boxGoal.state.getPositionAsVector()
	_boxGoal.rotation = _boxGoal.state.getRotationAsVector()
	return _boxGoal

func endOfTurn():
	print(state.position in level.objects and level.objects[state.position] is Box)
