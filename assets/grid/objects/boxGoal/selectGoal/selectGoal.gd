class_name SelectGoal
extends BoxGoal

static func New(_position: Vector3i, _level: Level, _state:BoxGoalState=SelectGoalState.new()) -> SelectGoal:
	var _selectGoal = baseNew(preload("res://assets/grid/objects/boxGoal/selectGoal/selectGoal.tscn").instantiate(), _position, _level, _state)
	_selectGoal.state.condition = "none"
	baseNewEnd(_selectGoal)
	return _selectGoal

func getHoverTitleText(): return "Level Select"
func getHoverBodyText():
	return super()\
	+ "Set:" + state.levelSet
