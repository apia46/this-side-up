class_name GameObject
extends Node3D

var level: Level
var state: ObjectState

var hovered: bool = false
var wasHovered: bool = false

static func baseNew(_object, _position: Vector3i, _level: Level, _state:=ObjectState.new()) -> GameObject:
	_object.level = _level
	_object.state = _state
	_object.state.position = _position
	return _object

static func baseNewEnd(_object):
	_object.position = _object.state.getPositionAsVector()
	_object.rotation = _object.state.getRotationAsVector()

static func isTileSolid(checkState:Level.STATES) -> bool:
	return checkState in [Level.STATES.SOLID, Level.STATES.BOX]

static func isTileNonsolid(checkState:Level.STATES) -> bool:
	return checkState in [Level.STATES.NONE]

func processHover():
	if hovered and !wasHovered: hover()
	elif !hovered and wasHovered: unhover()
	wasHovered = hovered

func hover():
	print(state.position)
	if has_node("outline"): 
		get_tree().create_tween().tween_property(get_node("outline").get_surface_override_material(0), "albedo_color", Color(1,1,1,1), 0.1)
		get_tree().create_tween().tween_property(get_node("outline"), "scale", Vector3(0.5,0.5,0.5), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
func unhover():
	if has_node("outline"): 
		get_tree().create_tween().tween_property(get_node("outline").get_surface_override_material(0), "albedo_color", Color(1,1,1,0), 0.1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		get_tree().create_tween().tween_property(get_node("outline"), "scale", Vector3(0.45,0.45,0.45), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
