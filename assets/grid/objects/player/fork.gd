class_name Fork
extends MeshInstance3D

@export var high: bool = false

var tween: Tween

func moveTo(_position:Vector3):
	if tween and tween.is_running(): tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "position", _position, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
