class_name SelectGoal
extends BoxGoal

static func New(_position: Vector3i, _level: Level, _state:=BoxGoalState.new()) -> SelectGoal:
	var _selectGoal = baseNew(preload("res://assets/grid/objects/selectGoal/selectGoal.tscn").instantiate(), _position, _level, _state)
	baseNewEnd(_selectGoal)
	return _selectGoal
