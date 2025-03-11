class_name CantInto
extends Node3D

@onready var mesh = %mesh

const COLORS = {
	RED = Color(1, 0, 0.4),
	BLUE1 = Color(0, 0.4, 1),
	BLUE2 = Color(0.267, 0.267, 1),
	BLUE3 = Color(0.4, 0, 1),
	GREEN = Color(0, 1, 0.4),
}

var speed : float
var goingTo : Vector3
var color : Color

static func New(_position:Vector3, _goingTo:Vector3, _speed:float=0.7, _color:Color=COLORS.RED, debug:=false):
	var _effect = preload("res://assets/effects/cantInto/cantInto.tscn").instantiate()
	if !debug: _effect.add_to_group("cantIntoEphemeral")
	_effect.position = _position
	_effect.goingTo = _goingTo
	_effect.speed = _speed
	_effect.color = _color
	return _effect

func _ready():
	create_tween().tween_property(self, "position", goingTo, speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	var tween = create_tween()
	%mesh.get_surface_override_material(0).albedo_color = color
	tween.tween_property(%mesh.get_surface_override_material(0), "albedo_color", color - Color(0, 0, 0, 1), speed)
	tween.tween_callback(queue_free)
