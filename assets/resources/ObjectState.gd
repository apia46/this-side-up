class_name ObjectState
extends Resource

const TAU_OVER_360 = 0.0174532925

@export var position: Vector3i
@export var rotation: Vector3i
@export var positionOffset: Vector3

func _init(_position = Vector3i(0,0,0), _rotation = 0, _positionOffset = Vector3(0,0,0)):
	position = _position
	rotation.y = _rotation
	positionOffset = _positionOffset

func moveRotated(vector:Vector3i) -> void:
	position += rotateVector3i(vector)

func getPositionAsVector() -> Vector3:
	return Vector3(position) + Vector3(0.5, 0, 0.5) + positionOffset

func getRotationAsVector() -> Vector3:
	return Vector3(rotation) * TAU_OVER_360
 
func getTileRelative(location:Vector3i, stateGrid:GridMap, lifted:=false) -> Level.STATES:
	return max(0, stateGrid.get_cell_item(positionRelative(location, lifted))) # cast this somehow

func getTile(location:Vector3i, stateGrid:GridMap) -> Level.STATES:
	return max(0, stateGrid.get_cell_item(location)) # cast this somehow

func rotateVector3i(vector:Vector3i, complicated:=false) -> Vector3i:
	var result = Vector3i(0,0,0)
	result.y = vector.y
	match rotation.y:
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
	if !complicated: return result
	# fuckkkkk
	match rotation.x:
		0:
			result.y = vector.y
			result.z = vector.z
		90:
			result.y = vector.z
			result.z = -vector.y
		180:
			result.y = -vector.y
			result.z = -vector.z
		270:
			result.y = -vector.z
			result.z = vector.y
	return result

func positionRelative(location:Vector3i, lifted:=false) -> Vector3i:
	return rotateVector3i(location) + position  + (Vector3i(0,0,0) if !lifted else Vector3i(0,1,0))
