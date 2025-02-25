class_name Trigger
extends GameObject

static func New(_position: Vector3i, _level: Level, _state:=ObjectState.new()) -> Trigger:
	var _trigger = baseNew(preload("res://assets/grid/objects/trigger/trigger.tscn").instantiate(), _position, _level, _state)
	baseNewEnd(_trigger)
	return _trigger

func inRange(_position):
	var difference = abs(_position - state.position)
	if difference.x > state.detectRange: return false
	if difference.z > state.detectRange: return false
	if state.checkYAxis and difference.y > state.detectRange: return false
	return true
