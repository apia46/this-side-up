class_name Player
extends Node3D

var level: Level

var state: ObjectState
@onready var fork: Fork = %fork
var held: Array[Box] = []
var holding: bool = false

var positionTween: Tween
var rotationTween: Tween

var won = false

const canUp = false
const betterControls = true

static func New(_position: Vector3i, _level: Level) -> Player:
	var _player = preload("res://assets/grid/objects/player/player.tscn").instantiate()
	_player.level = _level
	_player.state = ObjectState.new(_position, 0)
	_player.position = _player.state.getPositionAsVector()
	_player.rotation = _player.state.getRotationAsVector()
	return _player

func _input(event):
	if won: return
	var previousRotation = state.rotation
	
	if event.is_action_pressed("debug"):
		level.stateGrid.visible = !level.stateGrid.visible
	
	if event.is_action_pressed("win"):
		level.toNextLevel()
	
	if event.is_action_pressed("drop"):
		var objects = 0
		for object in held:
			if object.cantInto(state.positionRelative(Vector3i(2,objects,0), fork.high)): return
		objects = 0
		var highRelative = Box.cantLandOn(state.getTileRelative(Vector3i(2,-1,0), level.stateGrid, fork.high))
		for object in held:
			object.drop(state.positionRelative(Vector3i(2 + objects,0,0)))
			if highRelative: objects += 1
		held = []
		holding = false
		return
	
	if canUp and event.is_action_pressed("toggle_height"):
		if fork.high:
			if cantBodyInto(state.getTileRelative(Vector3i(1,0,0), level.stateGrid)): return
			fork.high = false
			fork.moveTo(Vector3(0,0,0))
			for object in held: object.moveTo(state.positionRelative(Vector3i(0,-1,0)), Vector3i(0,0,0), true)
		else:
			fork.high = true
			fork.moveTo(Vector3(0,1,0))
			for object in held: object.moveTo(state.positionRelative(Vector3i(0,1,0)), Vector3i(0,0,0), true)
	
	if event.is_action_pressed("movement"):
		position = state.getPositionAsVector()
		rotation = state.getRotationAsVector()
	
	if (event.is_action_pressed("forward") and Input.is_action_pressed("left") if betterControls else event.is_action_pressed("forward_left")):
		if cantBodyInto(state.getTileRelative(Vector3i(1,0,-1), level.stateGrid)): return
		if cantBodyInto(state.getTileRelative(Vector3i(1,0,0), level.stateGrid)): return
		if cantForkInto(state.getTileRelative(Vector3i(1,0,-2), level.stateGrid, fork.high)): return
		if holding and cantBodyInto(state.getTileRelative(Vector3i(1,0,-2), level.stateGrid, fork.high)): return
		#if holding and cantBodyInto(state.getTileRelative(Vector3i(2,0,0), level.stateGrid, fork.high)): return
		#if holding and cantBodyInto(state.getTileRelative(Vector3i(2,0,-1), level.stateGrid, fork.high)): return
		state.moveRotated(Vector3i(1,0,-1))
		state.rotation.y += 90
	elif (event.is_action_pressed("forward") and Input.is_action_pressed("right") if betterControls else event.is_action_pressed("forward_right")):
		if cantBodyInto(state.getTileRelative(Vector3i(1,0,1), level.stateGrid)): return
		if cantBodyInto(state.getTileRelative(Vector3i(1,0,0), level.stateGrid)): return
		if cantForkInto(state.getTileRelative(Vector3i(1,0,2), level.stateGrid, fork.high)): return
		#if holding and cantBodyInto(state.getTileRelative(Vector3i(2,0,0), level.stateGrid, fork.high)): return
		if holding and cantBodyInto(state.getTileRelative(Vector3i(1,0,2), level.stateGrid, fork.high)): return
		#if holding and cantBodyInto(state.getTileRelative(Vector3i(2,0,1), level.stateGrid, fork.high)): return
		state.moveRotated(Vector3i(1,0,1))
		state.rotation.y += -90
	elif event.is_action_pressed("forward"):
		if cantBodyInto(state.getTileRelative(Vector3i(1,0,0), level.stateGrid)): return
		if cantForkInto(state.getTileRelative(Vector3i(2,0,0), level.stateGrid, fork.high)): return
		if holding and cantBodyInto(state.getTileRelative(Vector3i(2,0,0), level.stateGrid, fork.high)): return
		state.moveRotated(Vector3i(1,0,0))
	elif (event.is_action_pressed("backward") and Input.is_action_pressed("left") if betterControls else event.is_action_pressed("backward_left")):
		if cantBodyInto(state.getTileRelative(Vector3i(-1,0,-1), level.stateGrid)): return
		if cantBodyInto(state.getTileRelative(Vector3i(-1,0,0), level.stateGrid)): return
		#if holding and cantBodyInto(state.getTileRelative(Vector3i(0,0,1), level.stateGrid, fork.high)): return
		#if holding and cantBodyInto(state.getTileRelative(Vector3i(-1,0,1), level.stateGrid, fork.high)): return
		state.moveRotated(Vector3i(-1,0,-1))
		state.rotation.y += -90
	elif (event.is_action_pressed("backward") and Input.is_action_pressed("right") if betterControls else event.is_action_pressed("backward_right")):
		if cantBodyInto(state.getTileRelative(Vector3i(-1,0,1), level.stateGrid)): return
		if cantBodyInto(state.getTileRelative(Vector3i(-1,0,0), level.stateGrid)): return
		#if holding and cantBodyInto(state.getTileRelative(Vector3i(0,0,-1), level.stateGrid, fork.high)): return
		#if holding and cantBodyInto(state.getTileRelative(Vector3i(-1,0,-1), level.stateGrid, fork.high)): return
		state.moveRotated(Vector3i(-1,0,1))
		state.rotation.y += 90
	elif event.is_action_pressed("backward"):
		if cantBodyInto(state.getTileRelative(Vector3i(-1,0,0), level.stateGrid)): return
		state.moveRotated(Vector3i(-1,0,0))
	else:
		return
	
	if positionTween and positionTween.is_running(): positionTween.kill()
	if rotationTween and rotationTween.is_running(): rotationTween.kill()
	
	var unfixedRotation = state.rotation
	
	rotation += Vector3(state.wrapSelfRotation(state.rotation)) * ObjectState.TAU_OVER_360
	
	positionTween = get_tree().create_tween()
	rotationTween = get_tree().create_tween()
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rotationTween.tween_property(self, "rotation", state.getRotationAsVector(), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	for object in held:
		object.moveTo(state.positionRelative(Vector3i(1,0,0)), unfixedRotation - previousRotation)
	
	# pick up?
	var offset = Vector3i(0,0,0)
	while state.positionRelative(Vector3i(1,0,0) + offset, fork.high) in level.objects.solid:
		var object = level.objects.solid[state.positionRelative(Vector3i(1,0,0) + offset, fork.high)]
		if object is Box and !object.held:
			held.append(object)
			object.hold()
			holding = true
			offset += Vector3i(0,1,0)
		else: break
	
	for object in level.objects.goals:
		if !level.objects.goals[object].hasBox(): return
	win()

static func cantBodyInto(checkState:Level.STATES) -> bool:
	return checkState in [Level.STATES.SOLID, Level.STATES.BOX]

static func cantForkInto(checkState:Level.STATES) -> bool:
	return checkState == Level.STATES.SOLID

func win():
	won = true
	await get_tree().create_timer(1.0).timeout
	level.toNextLevel()
