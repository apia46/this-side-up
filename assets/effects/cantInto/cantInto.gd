class_name CantInto
extends Node3D
var lifetime : float = 0.5

func _init(_lifetime:float, _position:Vector3):
	lifetime = _lifetime
	position = _position

func _ready():
	call_deferred("hgh")
	#get_tree().create_tween().tween_property(%mesh.get_surface_override_material(0), "albedo_color", Color(255, 0, 102, 0), lifetime)

func hgh():
	print(get_node("mesh"))
