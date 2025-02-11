class_name Player
extends Node3D

const FULL_ROTATION = Vector3(0, deg_to_rad(360), 0)

var level: Level
var state: ObjectState

var positionTween: Tween
var rotationTween: Tween

static func New(_position, _level) -> Player:
	var _player = preload("res://assets/grid/objects/player/player.tscn").instantiate()
	_player.level = _level
	_player.state = ObjectState.new(_position, 0)
	_player.position = _player.state.getPositionAsVector()
	_player.rotation = _player.state.getRotationAsVector()
	return _player

func _input(event):
	if event.is_action_pressed("movement"):
		position = state.getPositionAsVector()
		rotation = state.getRotationAsVector()
	
	if event.is_action_pressed("forward"):
		if cantBodyInto(state.getTileRelative(Vector3i(1,0,0), level.stateGrid)): return
		if cantForkInto(state.getTileRelative(Vector3i(2,0,0), level.stateGrid)): return
		state.moveRotated(Vector3i(1,0,0))
	elif event.is_action_pressed("forward_left"):
		if cantBodyInto(state.getTileRelative(Vector3i(1,0,-1), level.stateGrid)): return
		if cantForkInto(state.getTileRelative(Vector3i(1,0,-2), level.stateGrid)): return
		state.moveRotated(Vector3i(1,0,-1))
		state.rotation += 90
	elif event.is_action_pressed("forward_right"):
		state.moveRotated(Vector3i(1,0,1))
		state.rotation += -90
	elif event.is_action_pressed("backward"):
		if cantBodyInto(state.getTileRelative(Vector3i(-1,0,0), level.stateGrid)): return
		state.moveRotated(Vector3i(-1,0,0))
	elif event.is_action_pressed("backward_left"):
		state.moveRotated(Vector3i(-1,0,-1))
		state.rotation += -90
	elif event.is_action_pressed("backward_right"):
		state.moveRotated(Vector3i(-1,0,1))
		state.rotation += 90
	else:
		return
	
	if positionTween and positionTween.is_running():
		positionTween.kill()
	if rotationTween and rotationTween.is_running():
		rotationTween.kill()
	
	if state.rotation > 270:
		state.rotation -= 360
		rotation -= FULL_ROTATION
	if state.rotation < 0:
		state.rotation += 360
		rotation += FULL_ROTATION
	
	positionTween = get_tree().create_tween()
	rotationTween = get_tree().create_tween()
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rotationTween.tween_property(self, "rotation", state.getRotationAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

static func cantBodyInto(checkState:Level.STATES) -> bool:
	return checkState in [Level.STATES.SOLID, Level.STATES.BOX]

static func cantForkInto(checkState:Level.STATES) -> bool:
	return checkState == Level.STATES.SOLID
