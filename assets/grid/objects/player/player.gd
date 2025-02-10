class_name Player
extends Node3D

const FULL_ROTATION = Vector3(0, deg_to_rad(360), 0)

var state: ObjectState

var positionTween: Tween
var rotationTween: Tween

static func New(_position) -> Player:
	var _player = preload("res://assets/grid/objects/player/player.tscn").instantiate()
	_player.state = ObjectState.new(_position, 0)
	_player.position = _player.state.getPositionAsVector()
	_player.rotation = _player.state.getRotationAsVector()
	return _player

func _input(event):
	if event.is_action_pressed("forward"):
		state.moveRelative(Vector3i(1,0,0))
	elif event.is_action_pressed("forward_left"):
		state.moveRelative(Vector3i(1,0,-1))
		state.rotation += 90
	elif event.is_action_pressed("forward_right"):
		state.moveRelative(Vector3i(1,0,1))
		state.rotation += -90
	elif event.is_action_pressed("backward"):
		state.moveRelative(Vector3i(-1,0,0))
	elif event.is_action_pressed("backward_left"):
		state.moveRelative(Vector3i(-1,0,-1))
		state.rotation += -90
	elif event.is_action_pressed("backward_right"):
		state.moveRelative(Vector3i(-1,0,1))
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
	positionTween.tween_property(self, "position", state.getPositionAsVector(), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rotationTween.tween_property(self, "rotation", state.getRotationAsVector(), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
