class_name Fork
extends Node3D

var tween: Tween

func moveTo(_position:Vector3, instant:=false):
	if instant: %forks.position = _position+Vector3(-0.5,0.4,0)
	else:
		if tween and tween.is_running(): tween.kill()
		tween = create_tween()
		tween.tween_property(%forks, "position", _position+Vector3(-0.5,0.4,0), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
