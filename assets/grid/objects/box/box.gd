class_name Box
extends Node3D

var level: Level
var state: ObjectState
var held: bool = false

var positionTween: Tween
var rotationTween: Tween

static func New(_position: Vector3i, _level: Level) -> Box:
	var _box = preload("res://assets/grid/objects/box/box.tscn").instantiate()
	_box.level = _level
	_box.state = ObjectState.new(_position, 0)
	_box.state.positionOffset = Vector3(0, 0.5, 0)
	_box.position = _box.state.getPositionAsVector()
	_box.rotation = _box.state.getRotationAsVector()
	return _box

func hold():
	held = true
	state.positionOffset = Vector3(0,0.6,0)
	rotation = state.getRotationAsVector()
	
	if positionTween and positionTween.is_running(): positionTween.kill()
	positionTween = get_tree().create_tween()
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	level.stateGrid.set_cell_item(state.position, Level.STATES.BOX_HELD)

func moveTo(_position: Vector3i, _rotation:=Vector3i(0,0,0), changeHeight:=false):
	level.stateGrid.set_cell_item(state.position, -1)
	level.objects.solid.erase(state.position)
	var relativePosition = _position - state.position
	
	if changeHeight:
		state.position.y += _position.y
	else:
		state.position.x = _position.x
		state.position.z = _position.z
	state.rotation += _rotation
	
	if !held and cantLandOn(state.getTileRelative(Vector3i(0,-1,0), level.stateGrid)):
		while state.position.y > -5 and cantLandOn(state.getTileRelative(Vector3i(0,-1,0), level.stateGrid)):
			state.position.y -= 1
		var toRotate = Vector3i(0,0,0)
		match sign(relativePosition.x):
			1: toRotate.z = -90
			-1: toRotate.z = 90
		match sign(relativePosition.z):
			1: toRotate.x = 90
			-1: toRotate.x = -90
		print("=====")
		print("prerotateprefixed", state.rotation)
		rotation += Vector3(state.fixSelfRotation(state.rotation)) * ObjectState.TAU_OVER_360
		print("prerotatepostfixed", state.rotation)
		print("prerotated", state.rotation)
		print("torotate", toRotate)
		state.rotation = state.rotateRotation(toRotate)
		print("rotated", state.rotation)
		rotation += Vector3(state.fixSelfRotation(state.rotation)) * ObjectState.TAU_OVER_360
		print("fixed", state.rotation)
	
	if positionTween and positionTween.is_running(): positionTween.kill()
	if rotationTween and rotationTween.is_running(): rotationTween.kill()
	
	rotation += Vector3(state.wrapSelfRotation(state.rotation)) * ObjectState.TAU_OVER_360
	print("wrapped", state.rotation)
	
	positionTween = get_tree().create_tween()
	rotationTween = get_tree().create_tween()
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rotationTween.tween_property(self, "rotation", state.getRotationAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	level.stateGrid.set_cell_item(state.position, Level.STATES.BOX_HELD)
	level.objects.solid[state.position] = self

func cantInto(_position: Vector3i) -> bool:
	return state.getTile(_position, level.stateGrid) in [Level.STATES.SOLID, Level.STATES.BOX]

func drop(_position: Vector3i):
	held = false
	state.positionOffset = Vector3(0,0.5,0)
	if rotationTween and rotationTween.is_running(): rotationTween.kill()
	rotation = state.getRotationAsVector()
	level.stateGrid.set_cell_item(state.position, -1)
	moveTo(_position)
	level.stateGrid.set_cell_item(state.position, Level.STATES.BOX)

static func cantLandOn(checkState:Level.STATES) -> bool:
	return checkState in [Level.STATES.NONE]
