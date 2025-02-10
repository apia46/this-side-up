class_name ObjectState
extends Resource

@export var position: Vector3i
@export var rotation: int

func _init(_position = Vector3i(0,0,0), _rotation = 0):
	position = _position
	rotation = _rotation

func moveRelative(vector:Vector3i) -> void:
	position.y += vector.y
	match rotation:
		0:
			position.x += vector.x
			position.z += vector.z
		90:
			position.x += vector.z
			position.z -= vector.x
		180:
			position.x -= vector.x
			position.z -= vector.z
		270:
			position.x -= vector.z
			position.z += vector.x

func getPositionAsVector() -> Vector3:
	return Vector3(position) + Vector3(0.5, 0, 0.5)

func getRotationAsVector() -> Vector3:
	return Vector3(0, deg_to_rad(rotation), 0)
