class_name ObjectState
extends Resource

const TAU_OVER_360 = 0.0174532925

var position = Vector3i(0,0,0)
@export var rotation = Vector3i(0,0,0)
var positionOffset = Vector3(0,0,0)

func _init(_position = Vector3i(0,0,0), _rotation = 0, _positionOffset = Vector3(0,0,0)):
	position = _position
	rotation.y = _rotation
	positionOffset = _positionOffset

func moveRotated(vector:Vector3i) -> void:
	position += rotatePosition(vector)

func getPositionAsVector() -> Vector3:
	return Vector3(position) + Vector3(0.5, 0, 0.5) + positionOffset

func getRotationAsVector() -> Vector3:
	return Vector3(rotation) * TAU_OVER_360
 
func getTileRelative(location:Vector3i, stateGrid:GridMap, lifted:=false) -> Level.STATES:
	return max(0, stateGrid.get_cell_item(positionRelative(location, lifted))) as Level.STATES

func getTile(location:Vector3i, stateGrid:GridMap) -> Level.STATES:
	return max(0, stateGrid.get_cell_item(location)) as Level.STATES

func rotatePosition(vector:Vector3i) -> Vector3i:
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
	return result

func rotateRotation(vector:Vector3i) -> Array[Vector3i]: # rotates our rotation by an axis
	# can only rotate one axis at a time
	assert((1 if vector.x else 0) + (1 if vector.y else 0) + (1 if vector.z else 0) == 1)
	var result = rotation
	var rotationDifference = -rotation
	if vector.y:
		result.y = vector.y
	elif vector.x:
		if mod180(rotation.x) == 90 and mod180(rotation.y) == 90:
			result.y -= 90 * sign(rotation.x - 180)
			rotation.y -= 90 * sign(rotation.x - 180)
			result.z += 90
			rotation.z += 90
			#print("fixed to", rotation)
		match mod360(rotation.y):
			0: result.x += vector.x
			90: result.z -= vector.x * sign(rotation.x - 90)
			180: result.x -= vector.x
			270: result.z += vector.x * sign(rotation.x - 90)
	elif vector.z:
		if mod180(rotation.x) == 90 and mod180(rotation.y) == 0:
			result.y -= 90 * sign(rotation.x - 180)
			rotation.y -= 90 * sign(rotation.x - 180)
			result.z += 90
			rotation.z += 90
			#print("fixed to", rotation)
		match mod360(rotation.y):
			0: result.z -= vector.z * sign(rotation.x - 90)
			90: result.x -= vector.z
			180: result.z += vector.z * sign(rotation.x - 90)
			270: result.x += vector.z
	rotationDifference += rotation
	return [result, rotationDifference]

func wrapRotation(vector) -> Vector3i:
	var result = vector
	result.x = mod360(vector.x)
	result.y = mod360(vector.y)
	result.z = mod360(vector.z)
	return result

func wrapSelfRotation(vector) -> Vector3i:
	var fixed = wrapRotation(vector)
	rotation = fixed
	return fixed - vector

func positionRelative(location:Vector3i, lifted:=false) -> Vector3i:
	return rotatePosition(location) + position  + (Vector3i(0,0,0) if !lifted else Vector3i(0,1,0))

func mod360(_rotation:int) -> int:
	return (_rotation % 360 + 360) % 360

func mod180(_rotation:int) -> int:
	return (_rotation % 180 + 180) % 180

func facingUp() -> bool:
	return mod360(rotation.x) == mod360(rotation.z) and mod180(rotation.x) == 0
