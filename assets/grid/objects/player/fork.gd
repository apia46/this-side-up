class_name Fork
extends Node3D

@export var high: bool = false

var tween: Tween

func moveTo(_position:Vector3):
	if tween and tween.is_running(): tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(%forks, "position", _position+Vector3(-0.5,0.4,0), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
