class_name ObjectState
extends Resource

@export var position: Vector3i
@export var rotation: int
@export var positionOffset: Vector3
@export var rotationStateOffset: int

func _init(_position = Vector3i(0,0,0), _rotation = 0, _positionOffset = Vector3(0,0,0)):
	position = _position
	rotation = _rotation
	positionOffset = _positionOffset

func moveRotated(vector:Vector3i) -> void:
	position += rotatePosition(vector)

func getPositionAsVector() -> Vector3:
	return Vector3(position) + Vector3(0.5, 0, 0.5) + positionOffset

func getRotationAsVector() -> Vector3:
	return Vector3(0, deg_to_rad(rotation + rotationStateOffset), 0)
 
func getTileRelative(location:Vector3i, stateGrid:GridMap, lifted:=false) -> Level.STATES:
	return max(0, stateGrid.get_cell_item(positionRelative(location, lifted))) # cast this somehow

func rotatePosition(vector:Vector3i) -> Vector3i:
	var result = Vector3i(0,0,0)
	result.y = vector.y
	match rotation:
		0:
			result.x = vector.x
			result.z = vector.z
		90:
			result.x = vector.z
			result.z = -vector.x
		180:
			result.x = -vector.x
			result.z = -vector.z
		270:
			result.x = -vector.z
			result.z = vector.x
	return result

func positionRelative(location:Vector3i, lifted:=false) -> Vector3i:
	return rotatePosition(location) + position  + (Vector3i(0,0,0) if !lifted else Vector3i(0,1,0))
