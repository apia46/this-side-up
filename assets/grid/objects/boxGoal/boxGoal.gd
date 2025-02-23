class_name BoxGoal
extends GameObject

var level: Level
var state: ObjectState

static func New(_position: Vector3i, _level: Level, _state:=ObjectState.new()) -> BoxGoal:
	var _boxGoal = baseNew(preload("res://assets/grid/objects/boxGoal/boxGoal.tscn").instantiate(), _position, _level, _state)
	baseNewEnd(_boxGoal)
	return _boxGoal

func hasBox():
	return state.getTileRelative(Vector3i(0,0,0), level.stateGrid) in [Level.STATES.BOX] and level.objects.solid[state.position].state.facingUp()
