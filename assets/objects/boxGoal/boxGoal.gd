class_name BoxGoal
extends GameObject

static func New(_position: Vector3i, _level: Level, _state:BoxGoalState=BoxGoalState.new()) -> BoxGoal:
	var _boxGoal = baseNew(preload("res://assets/objects/boxGoal/boxGoal.tscn").instantiate(), _position, _level, _state)
	baseNewEnd(_boxGoal)
	return _boxGoal

func getBox():
	var box = level.getObject("solid", state.position)
	if !box or box is not Box or box.state.held or !box.state.facingUp(): return false
	return box

func getHoverTitleText(): return "Goal"
func getHoverBodyText():
	return super() +\
	("Effect:" + state.condition + "["+str(level.currentConditions[state.condition])+"/"+str(level.conditions[state.condition])+"]" if state.condition != "none" else "")
