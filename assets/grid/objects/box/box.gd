class_name Box
extends Node3D

const FULL_ROTATION = Vector3(0, deg_to_rad(360), 0)

var level: Level
var state: ObjectState
var held: bool = false

var positionTween: Tween
var rotationTween: Tween

static func New(_position: Vector3i, _level: Level) -> Box:
	var _box = preload("res://assets/grid/objects/box/box.tscn").instantiate()
	_box.level = _level
	_box.state = ObjectState.new(_position, 0)
	_box.position = _box.state.getPositionAsVector()
	_box.rotation = _box.state.getRotationAsVector()
	return _box

func hold(_rotation):
	assert(!held)
	held = true
	state.positionOffset = Vector3(0,0.25,0)
	state.rotation = _rotation
	rotation = state.getRotationAsVector()
	
	if positionTween and positionTween.is_running(): positionTween.kill()
	positionTween = get_tree().create_tween()
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	level.stateGrid.set_cell_item(state.position, Level.STATES.BOX_HELD)

func moveTo(_position: Vector3i, _rotation:=-1, changeHeight:=false):
	level.stateGrid.set_cell_item(state.position, -1)
	level.objects.erase(state.position)
	
	if changeHeight:
		state.position.y += _position.y
	else:
		state.position.x = _position.x
		state.position.z = _position.z
	if _rotation != -1: state.rotation = _rotation
	
	if state.rotation > 270:
		state.rotation -= 360
		rotation -= FULL_ROTATION
	if state.rotation < 0:
		state.rotation += 360
		rotation += FULL_ROTATION
	
	if positionTween and positionTween.is_running(): positionTween.kill()
	if rotationTween and rotationTween.is_running(): rotationTween.kill()
	positionTween = get_tree().create_tween()
	rotationTween = get_tree().create_tween()
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rotationTween.tween_property(self, "rotation", state.getRotationAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	level.stateGrid.set_cell_item(state.position, Level.STATES.BOX_HELD)
	level.objects[state.position] = self

func cantDrop() -> bool:
	return state.getTileRelative(Vector3i(1,0,0), level.stateGrid) in [Level.STATES.SOLID, Level.STATES.BOX]

func drop():
	held = false
	state.positionOffset = Vector3(0,0,0)
	level.stateGrid.set_cell_item(state.position, -1)
	moveTo(state.positionRelative(Vector3i(1,0,0)), state.rotation)
	level.stateGrid.set_cell_item(state.position, Level.STATES.BOX)

func endOfTurn(): return
